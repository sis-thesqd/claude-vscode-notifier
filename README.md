# Claude Code "done" notifier

A tiny helper for [Claude Code](https://claude.com/claude-code) on **macOS**.

When Claude finishes working, it gives you a soft chime and a notification banner
so you can go do something else and get pinged when it's ready. It stays **quiet
while you're actually looking at your editor**, and only speaks up once you've
tabbed away (Safari, another desktop, whatever).

## Requirements

- macOS
- Claude Code (terminal or the VS Code extension)
- Nothing else. It uses built-in macOS tools only.

## Install

```bash
git clone https://github.com/sis-thesqd/claude-vscode-notifier.git
cd claude-vscode-notifier
./install.sh
```

Then two quick one-time steps the installer reminds you about:

1. In Claude Code, run `/hooks` once (or restart it) so the new hook loads.
2. **System Settings → Notifications → Script Editor → Alert style: Banners.**
   This makes the banner fade after a few seconds instead of sticking around.
   (macOS shows these notifications under the name "Script Editor.")

That's it. Tab away from your editor and you'll get a soft ping when Claude finishes.

## Not using VS Code?

By default it stays quiet when **VS Code** is the app in front. If you use a
different editor, find its name by focusing it and running:

```bash
lsappinfo info -only name "$(lsappinfo front)"
```

Then open `~/.claude/claude-done-notify.sh` and change the `SKIP_APP` line near
the top (for example `Cursor`, or `Code - Insiders`).

You can also change the sound or volume in that same file.

## Turn it off

Delete the `Stop` block from `~/.claude/settings.json`, or just delete
`~/.claude/claude-done-notify.sh`.

## Good to know

- **This is a macOS desktop tool.** If you run Claude Code on a remote/cloud
  machine or in a browser, it can't pop a notification on your local Mac, that
  runs where Claude Code runs. For those setups, the VS Code extension's built-in
  "done" dot on the Claude icon is your best bet.
- It never steals focus and shows on whatever desktop/Space you're currently on.
