#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DIR=$(cd "$SCRIPT_DIR/.." && pwd)
source "$SCRIPT_DIR/links.sh"

# find the latest backup directory
latest_backup=$(ls -dt "$DIR/backup"/*/ 2>/dev/null | head -1)

for entry in "${links[@]}"; do
  src=$(echo "$entry" | awk '{print $1}')
  dst=$(echo "$entry" | awk '{$1=""; print $0}' | xargs)
  dst="${dst/#\~/$HOME}"

  # only remove if it's a symlink pointing to our repo
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$DIR/$src" ]; then
    rm "$dst"

    # restore from latest backup if available
    if [ -n "$latest_backup" ] && [ -f "$latest_backup/$src" ]; then
      cp "$latest_backup/$src" "$dst"
      echo "restore: $dst (from $latest_backup$src)"
    else
      echo "unlink: $dst (no backup found)"
    fi
  fi
done
