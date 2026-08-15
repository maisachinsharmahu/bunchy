# Bunchy - Copy Multiple at Once

**Collect copies from anywhere, paste them all together.**

Copying several images (or files) one at a time is tedious: copy, switch
apps, paste, switch back, copy the next one, repeat. Bunchy fixes that —
open it, start a bunch, then just keep copying normally wherever you
already are (Finder, Quick Look, Preview, Photos, anywhere). Every `⌘C`
you make gets added to a small floating shelf. When you're done, one
click combines everything into a single clipboard payload — paste once,
get everything.

It's a small native macOS menu bar app. No network access, no accounts,
no telemetry — see [PRIVACY.md](PRIVACY.md).

## How it works

1. Click the Bunchy menu bar icon → **Start New Bunch**. A small shelf
   window appears in the corner of your screen.
2. Go back to whatever you were doing — Finder, Quick Look (`Space` to
   preview, `⌘C` to copy), Preview, Photos — and copy things normally,
   one at a time. The shelf doesn't take focus away from what you're
   doing, so this doesn't interrupt your flow at all.
3. Each copy shows up in the shelf as a thumbnail. Made a mistake? Hover
   a thumbnail and click the × to remove it.
4. Click **Done — Copy All** in the shelf (or "Finish & Copy All" from
   the menu bar). Everything you collected is combined into one
   clipboard payload.
5. `⌘V` wherever you need them — most apps that accept multiple files or
   images (Finder, Mail, Slack, etc.) will paste all of them at once.

## Features

- **Non-intrusive shelf** — a floating panel that never steals focus from
  the app you're actively copying from (Finder, Quick Look, whatever).
- **Faithful capture** — each item keeps every representation it had at
  copy time (file reference, image data, etc.), so the final combined
  paste behaves like the original copies, not a lossy re-encoding.
- **Remove individual items** before finishing, or clear the whole bunch.
- **Menu bar only** — no Dock icon clutter; it just runs.
- **100% local.** No cloud, no sign-in, no data collection of any kind.

## Install

### Option A — Download (recommended)

Grab the latest `Bunchy.dmg` from the [Releases](../../releases) page and
open it. Inside you'll find `Bunchy.app` and **`Install Bunchy.command`**
— double-click the `.command` file for a guided, one-click install (it
copies the app to `/Applications`, clears the macOS download-quarantine
flag that causes the unnotarized-app warning below, and launches it).

Because Bunchy isn't notarized by Apple (that requires a paid $99/year
Developer Program membership, which this free, source-available project
doesn't have), opening it manually will otherwise trip a Gatekeeper
warning on first launch. If you hit "Bunchy.app is damaged" or "cannot be
opened," double-click **`Fix Permission Error.command`** (also in the
DMG) — it runs exactly one command (`xattr -cr`) and nothing else.

### Option B — Build from source

Requires Xcode (or the Xcode Command Line Tools) and Swift 5.9+.

```bash
git clone https://github.com/maisachinsharmahu/bunchy.git
cd bunchy
./scripts/build_app.sh
open "dist/Bunchy.app"
```

## How the capture works

There's no public macOS API to hook into `⌘C` system-wide, so Bunchy uses
the same technique every clipboard-history app on the Mac relies on:
while a bunch is active, it polls `NSPasteboard.general.changeCount`
(roughly 4 times a second) and reacts whenever it changes — no special
permission required, just standard pasteboard access available to any
app. Nothing is read from the clipboard except while a bunch is actively
running; there's no background clipboard monitoring the rest of the
time.

## Uninstall

1. Quit Bunchy from the menu bar.
2. Move `/Applications/Bunchy.app` to the Trash.
3. Optional cleanup:
   ```bash
   defaults delete com.bunchyapp.mac
   ```

## Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[PolyForm Noncommercial 1.0.0](LICENSE) — free for personal, educational,
and nonprofit use. Commercial use requires a separate license from the
copyright holder.
