#!/bin/bash
set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DIR=$(cd "$SCRIPT_DIR/.." && pwd)
source "$SCRIPT_DIR/links.sh"

for entry in "${links[@]}"; do
  src=$(echo "$entry" | awk '{print $1}')
  dst=$(echo "$entry" | awk '{$1=""; print $0}' | xargs)
  dst="${dst/#\~/$HOME}"

  if [ ! -f "$DIR/$src" ]; then
    echo "skip: $src (not found)"
    continue
  fi

  mkdir -p "$(dirname "$dst")"

  # backup if target is a regular file (not already a symlink)
  if [ -f "$dst" ] && [ ! -L "$dst" ]; then
    backup="$DIR/backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup"
    cp "$dst" "$backup/$src"
    echo "backup: $dst -> $backup/$src"
  fi

  ln -sf "$DIR/$src" "$dst"
  echo "link: $src -> $dst"
done
