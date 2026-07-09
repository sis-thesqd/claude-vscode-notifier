#!/bin/bash
# Claude Code notifier.  https://github.com/sis-thesqd/claude-vscode-notifier
# Two modes, picked by the first argument:
#   (no arg)  -> "Claude finished"           (wire to the Stop hook)
#   waiting   -> "Claude is waiting for you" (wire to the Notification hook --
#                fires when Claude needs a permission approval, and when it has
#                been sitting on a question/idle input for ~60 seconds)
# Both play a soft chime and show a banner, but ONLY when your editor is NOT
# the frontmost app -- so you get pinged when you've tabbed away and stay
# undisturbed while you're watching it.
#
# Once a day it also quietly updates ITSELF (this script file only, never your
# settings) from the repo above, so fixes reach you without reinstalling.
# Set CLAUDE_NOTIFY_AUTO_UPDATE=0 to turn that off.
#
# Uses macOS built-ins only (osascript + afplay + lsappinfo + curl). No extra installs.

# --- change this if your editor isn't VS Code ---
# Frontmost app name to stay quiet for. Find yours by focusing your editor and running:
#   lsappinfo info -only name "$(lsappinfo front)"
# VS Code = "Code"  |  VS Code Insiders = "Code - Insiders"  |  Cursor = "Cursor"
SKIP_APP="${CLAUDE_NOTIFY_SKIP_APP:-Code}"

# Sounds + volume (0.0 to 1.0). Swap the files for any .aiff in /System/Library/Sounds/.
SOUND_DONE="${CLAUDE_NOTIFY_SOUND:-/System/Library/Sounds/Tink.aiff}"
SOUND_WAITING="${CLAUDE_NOTIFY_SOUND_WAITING:-/System/Library/Sounds/Glass.aiff}"
VOLUME="${CLAUDE_NOTIFY_VOLUME:-0.3}"

# DON'T edit this file to customize -- auto-update would overwrite your changes.
# Put overrides in ~/.claude/claude-notify.conf instead (plain shell, survives
# updates), e.g.:   SKIP_APP="Cursor"
#                   VOLUME="0.5"
CONF="$HOME/.claude/claude-notify.conf"
[ -f "$CONF" ] && . "$CONF"

# --- self-update (script file only; settings.json is never touched) ---
RAW_URL="https://raw.githubusercontent.com/sis-thesqd/claude-vscode-notifier/main/claude-done-notify.sh"
self_update() {
  local marker="$HOME/.claude/.claude-notify-update-check"
  # At most one check per day.
  [ -f "$marker" ] && [ -n "$(find "$marker" -mtime -1 2>/dev/null)" ] && return 0
  touch "$marker"
  local tmp
  tmp=$(mktemp "$HOME/.claude/.claude-notify-update.XXXXXX") || return 0
  if curl -fsSL --max-time 5 "$RAW_URL" -o "$tmp" 2>/dev/null \
     && head -1 "$tmp" | grep -q '^#!/bin/bash' \
     && grep -q 'claude-vscode-notifier' "$tmp" \
     && ! cmp -s "$tmp" "$0"; then
    chmod +x "$tmp" && mv -f "$tmp" "$0"   # atomic swap; the running copy is unaffected
  else
    rm -f "$tmp"
  fi
}

# Frontmost app (no Accessibility/Automation permission needed).
front=$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | awk -F'"' '{print $4}')
if [ "$front" != "$SKIP_APP" ]; then
  if [ "$1" = "waiting" ]; then
    osascript -e 'display notification "Claude is waiting for you (question or approval)" with title "Claude Code"'
    [ -f "$SOUND_WAITING" ] && afplay -v "$VOLUME" "$SOUND_WAITING"
  else
    osascript -e 'display notification "Claude finished" with title "Claude Code"'
    [ -f "$SOUND_DONE" ] && afplay -v "$VOLUME" "$SOUND_DONE"
  fi
fi

# Update check runs last, in the background, so it never delays the ping.
[ "${CLAUDE_NOTIFY_AUTO_UPDATE:-1}" = "1" ] && ( self_update >/dev/null 2>&1 & )

exit 0
