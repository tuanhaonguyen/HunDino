"""Disk persistence, concurrency and error-path tests; no real account data."""
import importlib.util
import json
import tempfile
import threading
import unittest
import urllib.error
import urllib.request
from pathlib import Path

spec = importlib.util.spec_from_file_location("local_save", Path(__file__).with_name("local-save-server.py"))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class LocalSaveTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=Path(__file__).resolve().parent.parent / "local-save")
        self.path = Path(self.temp.name) / "profiles.json"
        self.store = module.DiskStore(self.path)

    def tearDown(self):
        self.temp.cleanup()

    def test_restart_retains_progress_and_previous_copy(self):
        self.assertEqual(self.store.get("player_1"), {"exists": False, "version": 0})
        self.store.compare_swap("player_1", 0, {"Coins": 80})
        self.store.compare_swap("player_1", 1, {"Coins": 57, "Weapon": "Bow"})
        restarted = module.DiskStore(self.path)
        self.assertEqual(restarted.get("player_1")["value"], {"Coins": 57, "Weapon": "Bow"})
        backup = json.loads(self.path.with_suffix(".previous.json").read_text())
        self.assertEqual(backup["profiles"]["player_1"]["value"]["Coins"], 80)

    def test_concurrent_writers_cannot_overwrite_newer_data(self):
        barrier = threading.Barrier(3)
        results = []

        def writer(coins):
            barrier.wait()
            results.append(self.store.compare_swap("player_1", 0, {"Coins": coins}))

        threads = [threading.Thread(target=writer, args=(coins,)) for coins in (20, 30)]
        for thread in threads:
            thread.start()
        barrier.wait()
        for thread in threads:
            thread.join()
        self.assertEqual(sum(result is not None for result in results), 1)
        self.assertEqual(self.store.get("player_1")["version"], 1)

    def test_corruption_is_not_replaced_with_defaults(self):
        self.path.write_text("broken data")
        with self.assertRaises(ValueError):
            module.DiskStore(self.path)
        with self.assertRaises(ValueError):
            self.store.compare_swap("player_1", 0, {"Coins": 80})
        self.assertEqual(self.path.read_text(), "broken data")

    def test_invalid_or_nonfinite_update_does_not_change_file(self):
        before = self.path.read_bytes()
        for version, value in [(True, {}), (-1, {}), (0, []), (0, {"Coins": float("nan")})]:
            with self.assertRaises(ValueError):
                self.store.compare_swap("player_1", version, value)
        self.assertEqual(self.path.read_bytes(), before)

    def test_http_protocol_and_conflict(self):
        server = module.Server(("127.0.0.1", 0), self.store)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        base = f"http://127.0.0.1:{server.server_port}"
        try:
            with urllib.request.urlopen(base + "/health") as response:
                self.assertEqual(json.load(response)["service"], module.SERVICE)
            for path in ("/profile/player_1", "/install"):
                with self.assertRaises(urllib.error.HTTPError) as caught:
                    urllib.request.urlopen(base + path)
                self.assertEqual(caught.exception.code, 403)
            headers = {"X-HunDino-Local": "v1", "Content-Type": "application/json"}
            request = urllib.request.Request(base + "/profile/player_1", headers=headers,
                                             data=json.dumps({"version": 0, "value": {"Coins": 15}}).encode())
            with urllib.request.urlopen(request) as response:
                self.assertEqual(json.load(response)["value"]["Coins"], 15)
            with self.assertRaises(urllib.error.HTTPError) as caught:
                urllib.request.urlopen(request)
            self.assertEqual(caught.exception.code, 409)
            request = urllib.request.Request(base + "/profile/../outside", headers=headers)
            with self.assertRaises(urllib.error.HTTPError):
                urllib.request.urlopen(request)
        finally:
            server.shutdown()
            server.server_close()
            thread.join()


if __name__ == "__main__":
    unittest.main(verbosity=2)
