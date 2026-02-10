#!/bin/bash
set -e

DIR=$(pwd)

# source -> target
links=(
  "zshrc                ~/.zshrc"
  "vimrc                ~/.vimrc"
  "tmux.conf            ~/.tmux.conf"
  "tool-versions        ~/.tool-versions"
  "default-python-packages ~/.default-python-packages"
  "config.omp.json      ~/.config.omp.json"
  "ghostty.conf         ~/Library/Application Support/com.mitchellh.ghostty/config"
  "karabiner.json       ~/.config/karabiner/karabiner.json"
)

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
