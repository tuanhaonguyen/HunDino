"""Shared pre-push/CI gate. Every invocation creates an independent report."""
import argparse
import datetime as dt
import json
import os
import platform
import re
import subprocess
import sys
import time
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GAME = ROOT / "HunDino"


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT).decode("utf-8", "replace").strip()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--report-dir")
    parser.add_argument("--legacy", action="store_true", help="Also run historical snapshot tests; failures block")
    args = parser.parse_args()
    stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    report = Path(args.report_dir) if args.report_dir else ROOT / ".reports" / f"check-{stamp}-{uuid.uuid4().hex[:8]}"
    report = report.resolve()
    report.mkdir(parents=True, exist_ok=True)
    results = []
    lock = json.loads((ROOT / "scripts/tool-lock.json").read_text(encoding="utf-8-sig"))
    suffix = ".exe" if platform.system() == "Windows" else ""
    tools = {name: ROOT / ".tools" / f'{name}-{spec["version"]}' / (name + suffix) for name, spec in lock.items()}
    manifest = json.loads((ROOT / "scripts/test-manifest.json").read_text())
    change_base = None
    event_path = os.getenv("GITHUB_EVENT_PATH")
    if event_path:
        payload = json.loads(Path(event_path).read_text(encoding="utf-8"))
        change_base = payload.get("before") or payload.get("pull_request", {}).get("base", {}).get("sha")
    elif (report / "push.json").exists():
        push_metadata = json.loads((report / "push.json").read_text())
        if push_metadata["updates"]:
            change_base = push_metadata["updates"][0][3]

    def run(name, command, cwd=ROOT, timeout=180):
        start = time.monotonic()
        try:
            completed = subprocess.run([str(x) for x in command], cwd=cwd, stdout=subprocess.PIPE,
                                       stderr=subprocess.STDOUT, timeout=timeout)
            output = completed.stdout.decode("utf-8", "replace")
            code = completed.returncode
        except (OSError, subprocess.TimeoutExpired) as error:
            output, code = str(error), 1
        (report / f"{name}.log").write_text(output, encoding="utf-8")
        results.append({"name": name, "passed": code == 0, "seconds": round(time.monotonic() - start, 2)})
        print(f'{"PASS" if code == 0 else "FAIL"} {name}', flush=True)
        if code:
            print(output[-3500:], flush=True)

    try:
        files = sorted(set(git("ls-files", "-z", "--cached", "--others", "--exclude-standard").split("\0")))
        files = [p for p in files if p and (ROOT / p).is_file()]
        # Scan code/text, never dump a matched credential into logs or reports.
        patterns = [re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
                    re.compile(r"\bgh[pousr]_[A-Za-z0-9]{30,}\b"),
                    re.compile(r"\bgithub_pat_[A-Za-z0-9_]{30,}\b"),
                    re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
                    re.compile(r"_\|WARNING:-DO-NOT-SHARE-THIS\.[^\s]{30,}")]
        security = []
        for path in files:
            local = ROOT / path
            if local.stat().st_size >= 100 * 1024 * 1024:
                security.append(f"GitHub file size limit: {path}")
            if local.name == ".env" or (local.name.startswith(".env.") and local.name != ".env.example") or local.suffix in (".pem", ".key"):
                security.append(f"Credential file tracked: {path}")
            if local.suffix.lower() in (".luau", ".lua", ".py", ".ps1", ".md", ".json", ".yml", ".yaml", ".toml", ".txt", ".cmd", ".sh"):
                content = local.read_text(encoding="utf-8-sig", errors="replace")
                if any(pattern.search(content) for pattern in patterns):
                    security.append(f"Possible credential: {path}")
        (report / "security.log").write_text("\n".join(security) or "No supported credential patterns or oversize files found.", encoding="utf-8")
        results.append({"name": "security-and-size", "passed": not security})
        source_roots = ("HunDino/src/", "HunDino/studio-pet-integration/", "HunDino/assets/", "scripts/")
        sources = [p for p in files if p.endswith((".luau", ".lua")) and p.startswith(source_roots)]
        if not sources:
            raise RuntimeError("No Luau sources found")
        source_list = report / "sources.json"
        source_list.write_text(json.dumps(sources), encoding="utf-8")
        run("luau-compile", [tools["lune"], "run", ROOT / "scripts/compile-sources.luau", source_list])
        python_files = [p for p in files if p.endswith(".py") and p.startswith(("scripts/", "HunDino/tools/"))]
        for path in python_files:
            compile((ROOT / path).read_text(encoding="utf-8-sig"), path, "exec")
        results.append({"name": "python-compile", "passed": True, "files": len(python_files)})
        for project in sorted(GAME.glob("*.project.json")):
            run("rojo-" + project.stem, [tools["rojo"], "build", project, "-o", report / (project.stem + ".rbxlx")])
        for test in manifest["automated"] + (list(manifest["legacy_baselines"]) if args.legacy else []):
            run("test-" + test, [tools["lune"], "run", "tools/test-" + test + ".luau"], cwd=GAME)
        (GAME / "local-save").mkdir(exist_ok=True)
        run("test-local-save-server", [sys.executable, "tools/test-local-save-server.py"], cwd=GAME)
        event = os.getenv("GITHUB_EVENT_NAME")
        if event == "pull_request":
            payload = json.loads(Path(os.environ["GITHUB_EVENT_PATH"]).read_text())
            pr = payload["pull_request"]
            allowed = pr["head"]["ref"] == "developer" and pr["base"]["ref"] == "main" and pr["head"]["repo"]["full_name"] == os.environ["GITHUB_REPOSITORY"]
            results.append({"name": "developer-to-main-only", "passed": allowed})
    except Exception as error:
        results.append({"name": "validator-error", "passed": False, "error": str(error)})
    passed = bool(results) and all(item["passed"] for item in results)
    metadata = {"utc": stamp, "commit": git("rev-parse", "HEAD"), "branch": git("branch", "--show-current"),
                "run_url": f'https://github.com/{os.getenv("GITHUB_REPOSITORY", "tunz2146/HunDino")}/actions/runs/{os.getenv("GITHUB_RUN_ID", "local")}',
                "event": os.getenv("GITHUB_EVENT_NAME", "local"), "change_base": change_base, "passed": passed, "results": results,
                "legacy_baselines_not_in_default_gate": manifest["legacy_baselines"], "manual": manifest["manual"]}
    (report / "report.json").write_text(json.dumps(metadata, indent=2, ensure_ascii=False), encoding="utf-8")
    lines = ["# HunDino validation report", "", f'UTC: {stamp}', f'Commit: `{metadata["commit"]}`',
             f'Branch: `{metadata["branch"]}`', f'Event: {metadata["event"]}', f'Result: **{"PASS" if passed else "FAIL"}**', "",
             "| Check | Result |", "|---|---|"]
    lines += [f'| {r["name"]} | {"PASS" if r["passed"] else "FAIL"} |' for r in results]
    if change_base and set(change_base) != {"0"}:
        changes = git("diff", "--stat", change_base, "HEAD")
        commits = git("log", "--oneline", f"{change_base}..HEAD")
    else:
        changes = git("show", "--stat", "--oneline", "HEAD")
        commits = git("log", "-1", "--oneline")
    lines += ["", "## Changes", "", "```", commits, changes, "```",
              "", "## Limits and known historical failures", "", manifest["manual"], ""]
    lines += [f'- `{name}`: {reason}' for name, reason in manifest["legacy_baselines"].items()]
    lines += ["", "Default gate: compile current sources, two Rojo builds, credential pattern/size checks, 25 portable Luau tests and local persistence tests.",
              "Historical tests above are excluded from the default gate, with known failures recorded. Run --legacy to reproduce them; that run fails.",
              "The report does not certify native gameplay or absence of all secrets/bugs."]
    (report / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f'Report: {report / "report.md"}', flush=True)
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
