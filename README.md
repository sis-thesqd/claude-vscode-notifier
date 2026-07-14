# Claude Code notifier

A tiny helper for [Claude Code](https://claude.com/claude-code) on **macOS**.

It gives you a soft chime and a notification banner in two situations:

1. **Claude finished** — the turn is completely done.
2. **Claude is waiting for you** — it asked you a question (pings the moment
   the dialog appears) or it needs a permission approval. Without this one,
   Claude can be silently stuck mid-task waiting on an answer while you think
   it's still working.

It stays **quiet while you're actually looking at your editor**, and only
speaks up once you've tabbed away (Safari, another desktop, whatever). Both use
a soft Glass chime by default; if you'd rather tell "finished" from "waiting"
by ear, set a different `SOUND_DONE` in your `.conf` (see below).

Install the optional `terminal-notifier` (below) and **clicking the banner jumps
you straight back to your editor**.

## Requirements

- macOS
- Claude Code (terminal or the VS Code extension)
- Nothing required to install. It uses built-in macOS tools by default.
- *Optional:* [`terminal-notifier`](https://github.com/julienXX/terminal-notifier)
  (`brew install terminal-notifier`) if you want **clicking the banner to bring
  your editor back to the front** (see "Click the banner" below). Without it,
  everything still works, the banner just isn't clickable.

## Install

```bash
git clone https://github.com/sis-thesqd/claude-vscode-notifier.git
cd claude-vscode-notifier
./install.sh
```

Then two quick one-time steps the installer reminds you about:

1. In Claude Code, run `/hooks` once (or restart it) so the new hook loads.
2. Make the banner fade on its own instead of sticking around:
   **System Settings → Notifications → _[app]_ → Alert style: Banners.**
   The _[app]_ is **"terminal-notifier"** if you installed it (see "Click the
   banner" below), otherwise **"Script Editor"** (the name macOS shows these
   under). If it isn't in the list yet, trigger one notification first so macOS
   registers it.

That's it. Tab away from your editor and you'll get a soft ping when Claude
finishes or when it's waiting on an answer from you.

**Already installed an older version?** Just `git pull` and run `./install.sh`
again — it re-copies the script and re-wires the hooks (upgrading its own old
entries in place) without touching anything else in your settings.

## Auto-update

Once a day, the script quietly checks this repo and replaces **itself** with
the latest version if one exists — so fixes and improvements reach you without
reinstalling. Details, so there are no surprises:

- It only ever updates the script file (`~/.claude/claude-done-notify.sh`).
  It **never touches** `~/.claude/settings.json` or anything else.
- The check runs in the background after a notification fires, so it never
  slows anything down. No network? It just skips and tries another day.
- To turn it off, put `CLAUDE_NOTIFY_AUTO_UPDATE=0` in `~/.claude/claude-notify.conf`.
- Rare exception: if a future version changes the *hook wiring* itself (not
  just the script), that still needs a one-time `git pull && ./install.sh`.
  We'll say so in Slack if it ever happens.

## Not using VS Code?

By default it stays quiet when **VS Code** is the app in front. If you use a
different editor, find its name by focusing it and running:

```bash
lsappinfo info -only name "$(lsappinfo front)"
```

Then create `~/.claude/claude-notify.conf` (plain shell) with the name you found:

```bash
SKIP_APP="Cursor"
```

You can also set `SOUND_DONE`, `SOUND_WAITING`, or `VOLUME` in that same file.
Don't edit `claude-done-notify.sh` itself — auto-update (below) would overwrite
your changes; the `.conf` file survives updates.

## Click the banner to open your editor

Install [`terminal-notifier`](https://github.com/julienXX/terminal-notifier):

```bash
brew install terminal-notifier
```

Once it's there the notifier uses it automatically, and **clicking the banner
brings your editor to the front** (whatever `SKIP_APP` is set to). Two one-time
notes:

- The banner now shows under the name **"terminal-notifier"**, so grant it
  notification permission if macOS asks, and set its Alert style to **Banners**
  (System Settings → Notifications → terminal-notifier).
- It figures out which app to open from your `SKIP_APP` name. If that lookup
  ever fails, set the bundle id yourself in `~/.claude/claude-notify.conf`:
  `CLAUDE_NOTIFY_CLICK_BUNDLE_ID="com.microsoft.VSCode"` (find any app's id with
  `osascript -e 'id of app "Code"'`).

No terminal-notifier? Nothing breaks, the banner just isn't clickable.

## Turn it off

Delete the `Stop`, `PreToolUse`, and `PermissionRequest` blocks that reference
`claude-done-notify.sh` from `~/.claude/settings.json`, or just delete
`~/.claude/claude-done-notify.sh`. To keep "done" pings but drop the "waiting"
ones (or the reverse), delete only the blocks for the mode you don't want.

## Good to know

- **This is a macOS desktop tool.** If you run Claude Code on a remote/cloud
  machine or in a browser, it can't pop a notification on your local Mac, that
  runs where Claude Code runs. For those setups, the VS Code extension's built-in
  "done" dot on the Claude icon is your best bet.
- It never steals focus and shows on whatever desktop/Space you're currently on.
- Under the hood, "waiting" pings ride two tool-event hooks: `PreToolUse` on
  the `AskUserQuestion` tool (question dialogs) and `PermissionRequest`
  (approval dialogs). Both fire in the terminal **and** the VS Code extension.
  We deliberately avoid the standalone `Notification` event, which the VS Code
  extension doesn't emit at all
  ([anthropics/claude-code#59718](https://github.com/anthropics/claude-code/issues/59718))
  and which never fires for question dialogs
  ([#59908](https://github.com/anthropics/claude-code/issues/59908)).
- The `PermissionRequest` hook runs async, so it only *notifies* — it never
  approves or denies anything on your behalf. You still make every call.
