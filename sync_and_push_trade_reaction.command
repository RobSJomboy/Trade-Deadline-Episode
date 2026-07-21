#!/bin/bash
# Trade Reaction overlay — sync + push
# Mirrors sync-and-push-v2.command (Trade Draft) / snub_draft.command (Snub Draft)
#
# Copies the working files from the "source" folder into the git repo folder,
# then commits + pushes. Edit the two paths below once to match your machine.

SOURCE_DIR="/Users/macbook61/Documents/claude/trade-reaction"
REPO_DIR="/Users/macbook61/Documents/claude/Trade-Reaction-Show"

set -e

echo "Syncing files..."
cp "$SOURCE_DIR/display.html" "$REPO_DIR/display.html"
cp "$SOURCE_DIR/control.html" "$REPO_DIR/control.html"
cp "$SOURCE_DIR/README.md" "$REPO_DIR/README.md"

cd "$REPO_DIR"

echo "Staging + committing..."
git add -A
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
git commit -m "Update Trade Reaction overlay — $TIMESTAMP" || echo "Nothing to commit."

echo "Pushing to GitHub..."
git push

echo "Done. GitHub Pages will update in a minute or two."
read -p "Press Enter to close..."
