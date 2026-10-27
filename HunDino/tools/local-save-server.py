"""Loopback-only Studio save helper. No cloud access or third-party packages."""
from __future__ import annotations

import argparse
import json
import os
import re
import tempfile
import threading
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parent.parent
SERVICE = "HunDinoLocalSaveV1"
MAX_BODY = 4 * 1024 * 1024
KEY = re.compile(r"player_-?\d{1,20}\Z")


def encode(value):
    return json.dumps(value, ensure_ascii=False, allow_nan=False, indent=2).encode("utf-8")


def atomic_write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(prefix=path.name + ".", suffix=".tmp", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(name, path)
    finally:
        if os.path.exists(name):
            os.unlink(name)


class DiskStore:
    def __init__(self, path):
        self.path = Path(path).resolve()
        self.lock = threading.Lock()
        if not self.path.exists():
            atomic_write(self.path, encode({"format": 1, "profiles": {}}))
        self.read()  # Corruption is an error, never replaced with a fresh profile.

    def read(self):
        data = json.loads(self.path.read_text(encoding="utf-8"))
        if not isinstance(data, dict) or data.get("format") != 1 or not isinstance(data.get("profiles"), dict):
            raise ValueError("Invalid save file format")
        for key, entry in data["profiles"].items():
            if not KEY.fullmatch(key) or not isinstance(entry, dict):
                raise ValueError("Invalid profile entry")
            if type(entry.get("version")) is not int or entry["version"] < 1 or not isinstance(entry.get("value"), dict):
                raise ValueError("Invalid profile version/value")
        return data

    def get(self, key):
        with self.lock:
            entry = self.read()["profiles"].get(key)
            return {"exists": False, "version": 0} if entry is None else {"exists": True, **entry}

    def compare_swap(self, key, version, value):
        if type(version) is not int or version < 0 or not isinstance(value, dict):
            raise ValueError("Invalid update")
        with self.lock:
            data = self.read()
            entry = data["profiles"].get(key)
            current = entry["version"] if entry else 0
            if current != version:
                return None
            entry = {"version": current + 1, "value": value}
            data["profiles"][key] = entry
            encoded = encode(data)
            # Keep the last complete file for manual recovery, never auto-reset.
            atomic_write(self.path.with_suffix(".previous.json"), self.path.read_bytes())
            atomic_write(self.path, encoded)
            return entry


class Server(ThreadingHTTPServer):
    daemon_threads = True

    def __init__(self, address, store):
        self.store = store
        super().__init__(address, Handler)


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *_args):
        pass

    def reply(self, status, payload):
        body = encode(payload)
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def allowed(self):
        if self.client_address[0] != "127.0.0.1" or self.headers.get("Origin"):
            self.reply(403, {"error": "Loopback Studio requests only"})
            return False
        if self.headers.get("Host") != f"127.0.0.1:{self.server.server_port}":
            self.reply(403, {"error": "Invalid host"})
            return False
        if self.path != "/health" and self.headers.get("X-HunDino-Local") != "v1":
            self.reply(403, {"error": "Studio protocol header required"})
            return False
        return True

    def profile_key(self):
        key = unquote(self.path.removeprefix("/profile/"))
        if not self.path.startswith("/profile/") or not KEY.fullmatch(key):
            raise ValueError("Invalid profile key")
        return key

    def do_GET(self):
        if not self.allowed():
            return
        try:
            if self.path == "/health":
                self.server.store.read()
                self.reply(200, {"service": SERVICE})
            elif self.path == "/install":
                files = {
                    "ProfileService": "src/data/ProfileService.luau",
                    "StudioLocalStore": "src/data/StudioLocalStore.luau",
                    "ProfileConfig": "src/data/ProfileConfig.luau",
                }
                self.reply(200, {name: (ROOT / path).read_text(encoding="utf-8-sig") for name, path in files.items()})
            else:
                self.reply(200, self.server.store.get(self.profile_key()))
        except ValueError:
            self.reply(500, {"error": "Save file or request invalid; existing data retained"})
        except OSError:
            self.reply(503, {"error": "Cannot read save file"})

    def do_POST(self):
        if not self.allowed():
            return
        try:
            key = self.profile_key()
            size = int(self.headers.get("Content-Length", "0"))
            if not 0 < size <= MAX_BODY or self.headers.get("Content-Type") != "application/json":
                self.reply(400, {"error": "Invalid body size/type"})
                return
            payload = json.loads(self.rfile.read(size), parse_constant=lambda _: (_ for _ in ()).throw(ValueError()))
            result = self.server.store.compare_swap(key, payload["version"], payload["value"])
            self.reply(409 if result is None else 200, {"error": "Concurrent update"} if result is None else result)
        except (ValueError, KeyError, TypeError):
            self.reply(400, {"error": "Invalid data; save file retained"})
        except OSError:
            self.reply(503, {"error": "Write failed; do not report saved"})


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=Path, default=ROOT / "local-save" / "profiles.json")
    parser.add_argument("--port", type=int, default=18764)
    parser.add_argument("--open-game", action="store_true")
    args = parser.parse_args()
    try:
        server = Server(("127.0.0.1", args.port), DiskStore(args.data))
    except OSError:
        url = f"http://127.0.0.1:{args.port}/health"
        with urllib.request.urlopen(url, timeout=3) as response:
            assert json.load(response)["service"] == SERVICE, "Port belongs to another program"
        if args.open_game:
            os.startfile(ROOT / "HunDino_SaveGame.rbxl")
        return
    if args.open_game:
        os.startfile(ROOT / "HunDino_SaveGame.rbxl")
    print(f"HunDino local saves: {args.data.resolve()}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
