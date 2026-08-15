# Privacy Policy

**Last updated: August 2026**

Bunchy is a local-only macOS utility. This policy is short because there
isn't much to disclose.

## What Bunchy does

- Watches the system clipboard (`NSPasteboard`), but **only while you've
  explicitly started a bunch** — never in the background otherwise.
- When it detects a new copy while a bunch is active, it stores a copy of
  that pasteboard item's data in memory, so it can be combined with the
  rest and written back to the clipboard when you finish.
- Shows those collected items in a small on-screen shelf while you work.

## What Bunchy does not do

- **No network access.** Bunchy makes no HTTP requests, has no analytics
  SDK, no crash reporter, and no auto-update pinging. The source is
  public — verify it yourself, or check with Little Snitch or the macOS
  network monitor.
- **No account, no sign-in, no cloud sync.**
- **No telemetry or usage tracking of any kind.**
- **No clipboard monitoring outside of an active bunch.** Between
  sessions, Bunchy doesn't read or watch the clipboard at all.
- **No disk access beyond what a normal copy already touches.** Bunchy
  doesn't scan your files or folders — it only sees what you explicitly
  copy while a bunch is running, the same data any paste would receive.

## Data storage

Collected items live in memory only, for the duration of one bunch
session. Nothing is written to disk, and nothing persists after you
finish (Done) or cancel a bunch. The only setting Bunchy keeps between
launches is none — there's no preferences file today.

## Questions

Open an issue on the GitHub repository.
