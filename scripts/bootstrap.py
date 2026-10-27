"""Install repository-local, version/hash-pinned tools; no global changes."""
import hashlib
import io
import json
import os
import platform
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main():
    target = platform.system().lower()
    if target not in ("windows", "linux") or platform.machine().lower() not in ("amd64", "x86_64"):
        raise SystemExit("Supported: Windows/Linux x86_64 with Python 3.10+.")
    lock = json.loads((ROOT / "scripts/tool-lock.json").read_text(encoding="utf-8-sig"))
    for name, tool in lock.items():
        asset = tool["platforms"][target]
        if len(asset["sha256"]) != 64:
            raise SystemExit(f"Missing SHA256 for {name}")
        destination = ROOT / ".tools" / f'{name}-{tool["version"]}'
        executable = destination / (name + (".exe" if target == "windows" else ""))
        # Verify the executable on every use, including cached installations.
        marker = destination / "executable.sha256"
        if executable.exists() and marker.exists():
            actual = hashlib.sha256(executable.read_bytes()).hexdigest()
            if actual == marker.read_text().strip():
                print(f'{name} {tool["version"]}: verified cache', flush=True)
                continue
        request = urllib.request.Request(asset["url"], headers={"User-Agent": "HunDino-Setup"})
        with urllib.request.urlopen(request, timeout=120) as response:
            archive = response.read()
        if hashlib.sha256(archive).hexdigest() != asset["sha256"]:
            raise SystemExit(f"SHA256 mismatch: {name}; installation stopped")
        with zipfile.ZipFile(io.BytesIO(archive)) as package:
            members = [p for p in package.namelist() if Path(p).name == executable.name]
            if len(members) != 1:
                raise SystemExit(f"Unexpected release archive: {name}")
            data = package.read(members[0])
        destination.mkdir(parents=True, exist_ok=True)
        executable.write_bytes(data)
        executable.chmod(0o755)
        marker.write_text(hashlib.sha256(data).hexdigest())
        print(f'{name} {tool["version"]}: installed, SHA256 verified', flush=True)


if __name__ == "__main__":
    main()
