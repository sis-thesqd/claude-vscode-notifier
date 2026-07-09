#!/bin/bash
# One-shot installer for the Claude Code notifier.
# Copies the script into ~/.claude and adds Stop + Notification hooks to
# ~/.claude/settings.json (without clobbering anything already in there).
# Stop = "Claude finished". Notification = "Claude is waiting for you"
# (permission approvals + questions idle ~60s). macOS only.
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
wanted = {
    "Stop": "bash ~/.claude/claude-done-notify.sh",
    "Notification": "bash ~/.claude/claude-done-notify.sh waiting",
}
data = {}
if os.path.exists(p):
    try:
        with open(p) as f:
            data = json.load(f)
    except Exception:
        print("!! ~/.claude/settings.json isn't valid JSON, so I won't touch it.")
        print("   Add the hooks by hand (see the README).")
        sys.exit(1)
hooks = data.setdefault("hooks", {})
changed = False
for event, cmd in wanted.items():
    groups = hooks.setdefault(event, [])
    already = any(h.get("command", "") == cmd
                  for g in groups for h in g.get("hooks", []))
    if already:
        print(f"{event} hook already present, leaving it as-is.")
    else:
        groups.append({"hooks": [{"type": "command", "command": cmd, "async": True, "timeout": 10}]})
        changed = True
        print(f"Added the {event} hook to ~/.claude/settings.json")
if changed:
    with open(p, "w") as f:
        json.dump(data, f, indent=2)
PY

echo
echo "Two quick manual steps to finish:"
echo "  1. In Claude Code, run  /hooks  once (or restart it) so the hook loads."
echo "  2. System Settings > Notifications > Script Editor > Alert style: Banners"
echo "     (so the banner fades on its own instead of sticking around)."
echo
echo "Done. Tab away from your editor and you'll get a soft ping when Claude finishes"
echo "or when it's stuck waiting on a question/approval from you."
