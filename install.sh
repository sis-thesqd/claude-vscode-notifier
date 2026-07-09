#!/bin/bash
# One-shot installer for the Claude Code notifier.
# Copies the script into ~/.claude and wires three hooks in ~/.claude/settings.json
# (upgrading its own older entries, never touching anything else):
#   Stop                          -> "Claude finished" ping
#   PreToolUse (AskUserQuestion)  -> "Claude is waiting for you" ping, the moment
#                                    a question dialog appears
#   PermissionRequest             -> same waiting ping, the moment a permission
#                                    approval dialog appears (async, so it only
#                                    notifies -- it never allows/denies for you)
# Both waiting hooks are tool-events, which fire in the VS Code extension too
# (the standalone Notification event does not -- anthropics/claude-code#59718).
# macOS only.
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
SCRIPT = "claude-done-notify.sh"
canonical = [
    ("Stop", None, "bash ~/.claude/claude-done-notify.sh"),
    ("PreToolUse", "AskUserQuestion", "bash ~/.claude/claude-done-notify.sh waiting"),
    ("PermissionRequest", None, "bash ~/.claude/claude-done-notify.sh waiting"),
]
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
# Remove EVERY hook group that references our script, across all events, so
# re-running upgrades old wiring cleanly and drops hooks we've since retired
# (e.g. an old Notification entry). Anything not ours is left untouched.
for ev in list(hooks.keys()):
    kept = [g for g in hooks[ev]
            if not any(SCRIPT in h.get("command", "") for h in g.get("hooks", []))]
    if kept:
        hooks[ev] = kept
    else:
        del hooks[ev]  # don't leave an empty event array behind
for ev, matcher, cmd in canonical:
    group = {"hooks": [{"type": "command", "command": cmd, "async": True, "timeout": 10}]}
    if matcher:
        group["matcher"] = matcher
    hooks.setdefault(ev, []).append(group)
    print("Wired %s%s." % (ev, " (%s)" % matcher if matcher else ""))
with open(p, "w") as f:
    json.dump(data, f, indent=2)
PY

echo
echo "Two quick manual steps to finish:"
echo "  1. In Claude Code, run  /hooks  once (or restart it) so the hooks load."
echo "  2. System Settings > Notifications > Script Editor > Alert style: Banners"
echo "     (so the banner fades on its own instead of sticking around)."
echo
echo "Done. Tab away from your editor and you'll get a soft ping when Claude finishes"
echo "or the moment it's waiting on a question/approval from you."
