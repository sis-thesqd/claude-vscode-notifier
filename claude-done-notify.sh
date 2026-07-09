#!/bin/bash
# Claude Code notifier.
# Two modes, picked by the first argument:
#   (no arg)  -> "Claude finished"           (wire to the Stop hook)
#   waiting   -> "Claude is waiting for you" (wire to the Notification hook --
#                fires when Claude needs a permission approval, and when it has
#                been sitting on a question/idle input for ~60 seconds)
# Both play a soft chime and show a banner, but ONLY when your editor is NOT
# the frontmost app -- so you get pinged when you've tabbed away and stay
# undisturbed while you're watching it.
#
# Uses macOS built-ins only (osascript + afplay + lsappinfo). No extra installs.

# --- change this if your editor isn't VS Code ---
# Frontmost app name to stay quiet for. Find yours by focusing your editor and running:
#   lsappinfo info -only name "$(lsappinfo front)"
# VS Code = "Code"  |  VS Code Insiders = "Code - Insiders"  |  Cursor = "Cursor"
SKIP_APP="${CLAUDE_NOTIFY_SKIP_APP:-Code}"

# Sounds + volume (0.0 to 1.0). Swap the files for any .aiff in /System/Library/Sounds/.
SOUND_DONE="${CLAUDE_NOTIFY_SOUND:-/System/Library/Sounds/Tink.aiff}"
SOUND_WAITING="${CLAUDE_NOTIFY_SOUND_WAITING:-/System/Library/Sounds/Glass.aiff}"
VOLUME="${CLAUDE_NOTIFY_VOLUME:-0.3}"

# Frontmost app (no Accessibility/Automation permission needed).
front=$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | awk -F'"' '{print $4}')
[ "$front" = "$SKIP_APP" ] && exit 0

if [ "$1" = "waiting" ]; then
  osascript -e 'display notification "Claude is waiting for you (question or approval)" with title "Claude Code"'
  [ -f "$SOUND_WAITING" ] && afplay -v "$VOLUME" "$SOUND_WAITING"
else
  osascript -e 'display notification "Claude finished" with title "Claude Code"'
  [ -f "$SOUND_DONE" ] && afplay -v "$VOLUME" "$SOUND_DONE"
fi
