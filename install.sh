#!/bin/bash
# One-shot installer for the Claude Code "done" notifier.
# Copies the script into ~/.claude and adds a Stop hook to ~/.claude/settings.json
# (without clobbering anything already in there). macOS only.
set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_SRC="$(cd "$(dirname "$0")" && pwd)/claude-done-notify.sh"
SCRIPT_DST="$CLAUDE_DIR/claude-done-notify.sh"

if [ "$(uname)" != "Darwin" ]; then
  echo "This tool is macOS-only (it uses osascript / afplay / lsappinfo)."
  exit 1
fi

mkdir -p "$CLAUDE_DIR"
cp "$SCRIPT_SRC" "$SCRIPT_DST"
chmod +x "$SCRIPT_DST"
echo "Installed $SCRIPT_DST"

python3 - <<'PY'
import json, os, sys
p = os.path.expanduser("~/.claude/settings.json")
cmd = "bash ~/.claude/claude-done-notify.sh"
data = {}
if os.path.exists(p):
    try:
        with open(p) as f:
            data = json.load(f)
    except Exception:
        print("!! ~/.claude/settings.json isn't valid JSON, so I won't touch it.")
        print("   Add the Stop hook by hand (see the README).")
        sys.exit(1)
hooks = data.setdefault("hooks", {})
stop = hooks.setdefault("Stop", [])
already = any("claude-done-notify.sh" in h.get("command", "")
             for g in stop for h in g.get("hooks", []))
if already:
    print("Stop hook already present, leaving settings.json as-is.")
else:
    stop.append({"hooks": [{"type": "command", "command": cmd, "async": True, "timeout": 10}]})
    with open(p, "w") as f:
        json.dump(data, f, indent=2)
    print("Added the Stop hook to ~/.claude/settings.json")
PY

echo
echo "Two quick manual steps to finish:"
echo "  1. In Claude Code, run  /hooks  once (or restart it) so the hook loads."
echo "  2. System Settings > Notifications > Script Editor > Alert style: Banners"
echo "     (so the banner fades on its own instead of sticking around)."
echo
echo "Done. Tab away from your editor and you'll get a soft ping when Claude finishes."
