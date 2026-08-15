#!/bin/bash
# If Bunchy won't open ("app is damaged" or "unidentified developer"),
# just double-click this file. That's it — one command, nothing else.
xattr -cr "/Applications/Bunchy.app"
echo
echo "Done. Try opening Bunchy again — it should work now."
read -n 1 -s -r -p "Press any key to close..."
