# Claude Code notifier

A tiny helper for [Claude Code](https://claude.com/claude-code) on **macOS**.

It gives you a soft chime and a notification banner in two situations:

1. **Claude finished** — the turn is completely done.
2. **Claude is waiting for you** — it needs a permission approval (pings right
   away) or it asked you a question and has been sitting idle for about a
   minute. Without this one, Claude can be silently stuck mid-task waiting on
   an answer while you think it's still working.

It stays **quiet while you're actually looking at your editor**, and only
speaks up once you've tabbed away (Safari, another desktop, whatever). The two
cases use different sounds (Tink = done, Glass = waiting) so you can tell them
apart without looking.

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

That's it. Tab away from your editor and you'll get a soft ping when Claude
finishes or when it's waiting on an answer from you.

**Already installed an older version?** Just `git pull` and run `./install.sh`
again — it re-copies the script and adds the new Notification hook without
touching anything else in your settings.

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

Delete the `Stop` and `Notification` blocks from `~/.claude/settings.json`, or
just delete `~/.claude/claude-done-notify.sh`. To keep "done" pings but drop
the "waiting" ones (or the reverse), delete only that one block.

## Good to know

- **This is a macOS desktop tool.** If you run Claude Code on a remote/cloud
  machine or in a browser, it can't pop a notification on your local Mac, that
  runs where Claude Code runs. For those setups, the VS Code extension's built-in
  "done" dot on the Claude icon is your best bet.
- It never steals focus and shows on whatever desktop/Space you're currently on.
