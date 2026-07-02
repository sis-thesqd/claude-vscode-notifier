#!/bin/bash
# Claude Code "done" notifier.
# Plays a soft chime and shows a banner when a Claude Code turn finishes,
# but ONLY when your editor is NOT the frontmost app -- so you get pinged
# when you've tabbed away and stay undisturbed while you're watching it.
#
# Uses macOS built-ins only (osascript + afplay + lsappinfo). No extra installs.

# --- change this if your editor isn't VS Code ---
# Frontmost app name to stay quiet for. Find yours by focusing your editor and running:
#   lsappinfo info -only name "$(lsappinfo front)"
# VS Code = "Code"  |  VS Code Insiders = "Code - Insiders"  |  Cursor = "Cursor"
SKIP_APP="${CLAUDE_NOTIFY_SKIP_APP:-Code}"

# Sound + volume (0.0 to 1.0). Swap the file for any .aiff in /System/Library/Sounds/.
SOUND="${CLAUDE_NOTIFY_SOUND:-/System/Library/Sounds/Tink.aiff}"
VOLUME="${CLAUDE_NOTIFY_VOLUME:-0.3}"

# Frontmost app (no Accessibility/Automation permission needed).
front=$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | awk -F'"' '{print $4}')
[ "$front" = "$SKIP_APP" ] && exit 0

osascript -e 'display notification "Claude finished" with title "Claude Code"'
[ -f "$SOUND" ] && afplay -v "$VOLUME" "$SOUND"
