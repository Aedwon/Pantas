#!/bin/zsh -l
# Double-click this file in Finder to start the Pantas Lesson Author.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
cd "$(dirname "$0")"

if ! command -v node >/dev/null; then
  echo "Could not find Node.js on this Mac."
  echo "Install it from https://nodejs.org, then double-click this file again."
  read -k1 -s "?Press any key to close..."
  exit 1
fi

node server.mjs
if [ $? -ne 0 ]; then
  echo ""
  read -k1 -s "?The Lesson Author stopped with an error (see above). Press any key to close..."
fi
