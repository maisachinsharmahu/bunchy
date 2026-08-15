# Security Policy

## Reporting a Vulnerability

If you find a security issue in Bunchy, please open a GitHub issue, or if
it's sensitive, use GitHub's private "Report a vulnerability" flow under
the Security tab of this repository rather than a public issue.

Please include:
- macOS version and Bunchy version
- Steps to reproduce
- What you expected vs. what happened

## Scope notes

- Bunchy is an unsigned, ad-hoc-signed, non-notarized source-available
  binary (no paid Apple Developer Program membership). This means
  Gatekeeper will warn on first launch — see the README for how to
  verify what you're running before opening it.
- Bunchy requests no Accessibility, Screen Recording, Full Disk Access,
  or network entitlements. If a future version ever asks for one of
  these, treat that as suspicious and check the diff before upgrading.
- Bunchy reads the system clipboard while a bunch is active, by design —
  that's the entire feature. It never reads the clipboard outside of an
  explicitly-started session, and everything it captures stays in memory
  until you finish or cancel.
