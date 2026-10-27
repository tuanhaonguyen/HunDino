"""Guard remote refs and test the exact commit being sent."""
import datetime as dt
import json
import subprocess
import sys
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True).strip()


def main():
    updates = [line.split() for line in sys.stdin if line.strip()]
    stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    report = ROOT / ".reports" / f"push-{stamp}-{uuid.uuid4().hex[:8]}"
    report.mkdir(parents=True)
    reason = None
    if len(sys.argv) < 2 or sys.argv[1] != "origin":
        reason = "Only the configured origin is allowed."
    elif not updates or any(len(u) != 4 or u[0] != "refs/heads/developer" or u[2] != "refs/heads/developer" or set(u[1]) == {"0"} for u in updates):
        reason = "Only developer -> developer pushes are allowed. Direct main pushes, deletions and tags are blocked."
    elif git("branch", "--show-current") != "developer":
        reason = "The current branch must be developer."
    elif any(u[1] != git("rev-parse", "HEAD") for u in updates):
        reason = "Only the current HEAD can be tested and pushed."
    elif git("status", "--porcelain"):
        reason = "Uncommitted files detected. Commit all intended changes first so the tested files match HEAD."
    if reason:
        (report / "report.md").write_text(f"# Push blocked\n\n{reason}\n", encoding="utf-8")
        print(f"BLOCKED: {reason}\nReport: {report / 'report.md'}", file=sys.stderr)
        return 1
    (report / "push.json").write_text(json.dumps({"utc": stamp, "updates": updates, "phase": "pre-push validation; remote receipt is reported by Git/Actions"}, indent=2))
    setup = subprocess.run([sys.executable, str(ROOT / "scripts/bootstrap.py")], cwd=ROOT)
    if setup.returncode:
        (report / "report.md").write_text("# Push blocked\n\nTool bootstrap failed.\n")
        return setup.returncode
    return subprocess.call([sys.executable, str(ROOT / "scripts/validate.py"), "--report-dir", str(report)], cwd=ROOT)


if __name__ == "__main__":
    sys.exit(main())
