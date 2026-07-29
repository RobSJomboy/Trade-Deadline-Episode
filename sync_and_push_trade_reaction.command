#!/bin/bash
# Trade Reaction overlay — commit + push
# The repo folder IS the working folder, so there's nothing to copy first.
# (The old version copied from /Users/macbook61/... — paths from a different machine,
#  so it errored out on every run here.)

set -e
cd "$(dirname "$0")"

echo "Staging + committing..."
git add -A
git commit -m "Update Trade Reaction overlay — $(date '+%Y-%m-%d %H:%M:%S')" || echo "Nothing to commit."

echo "Pushing to GitHub..."
git push

echo "Done. GitHub Pages will update in a minute or two."
read -p "Press Enter to close..."
