# Troubleshooting

## "Bunchy.app is damaged and can't be opened. You should move it to the Trash."

This is **not actual damage** — it's macOS Gatekeeper being strict about
apps that (a) aren't notarized by Apple and (b) were downloaded through a
browser, which tags the file with a "quarantine" flag. Bunchy isn't
notarized because that requires a paid $99/year Apple Developer Program
membership, which this free, source-available project doesn't have.

**Do not click "Move to Trash."** Fix it instead — pick one:

### Option A — double-click the fix file (easiest)

The DMG includes **`Fix Permission Error.command`**, right next to the
app icon. Double-click it, confirm the one "downloaded from the
Internet, are you sure?" dialog, and it's fixed. This runs exactly one
command:

```bash
xattr -cr "/Applications/Bunchy.app"
```

### Option B — the installer script

**`Install Bunchy.command`** (also in the DMG) does the same fix as part
of a full install: copies Bunchy to `/Applications`, clears the
quarantine flag, and launches it.

### Option C — Terminal, manually

```bash
xattr -cr "/Applications/Bunchy.app"
```

Then double-click Bunchy.app again — it will open normally.

## The shelf steals focus / interrupts what I'm copying from

It shouldn't — the shelf is a non-activating panel specifically so it
never becomes the frontmost app. If you're seeing this, please open a
GitHub issue with your macOS version and what app you were copying from.

## An item shows a blank/spinning thumbnail

Thumbnail generation is asynchronous and can lag slightly behind the
capture, especially for large files. If it never resolves, the item is
still captured correctly (the pasteboard data itself, not just the
preview) — the final paste isn't affected either way.

## Still stuck?

Open an issue: <https://github.com/maisachinsharmahu/bunchy/issues>
