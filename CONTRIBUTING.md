# Contributing to Bunchy

Thanks for considering a contribution! Bunchy is a small, focused app —
please keep PRs scoped and avoid adding new permissions/entitlements
without discussion in an issue first (privacy/minimal-permissions is a
core design goal, see [PRIVACY.md](PRIVACY.md)).

## Setup

```bash
git clone https://github.com/maisachinsharmahu/bunchy.git
cd bunchy
swift build
```

Open `Package.swift` in Xcode for a full IDE experience, or edit with any
editor and use `swift build` / `./scripts/build_app.sh` from the
terminal.

## Project layout

```
Sources/Bunchy/
  main.swift              — entry point, activation policy
  AppDelegate.swift        — menu bar, shelf panel management
  ClipboardCollector.swift — pasteboard polling + capture engine
  CollectedItem.swift      — one captured pasteboard snapshot
  ShelfView.swift          — the floating shelf UI (SwiftUI)
```

## Reporting bugs

Open a GitHub issue with your macOS version, Bunchy version, and repro
steps.

## Pull requests

- Keep changes focused; one logical change per PR.
- Run `./scripts/build_app.sh` and confirm it builds cleanly before
  submitting.
- Describe *why*, not just *what*, in the PR description.
