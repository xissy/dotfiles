#!/bin/bash
# Claude Code statusline inspired by oh-my-posh configuration
# Line 1: Repo/code context (cool blues/cyans) + hostname
# Line 2: Session/context info (complementary warm tones) + language versions

input=$(cat)

# Extract data from JSON
dir=$(echo "$input" | jq -r '.workspace.current_dir')
# Show full path with ~ for home directory
dir_display="${dir/#$HOME/~}"
model=$(echo "$input" | jq -r '.model.display_name // .model.id')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Hostname info (from oh-my-posh OS segment)
hostname_short=$(hostname -s)

# Git info
if cd "$dir" 2>/dev/null; then
  branch=$(git -c core.useBuiltinFSMonitor=false branch --show-current 2>/dev/null)
  diff_stats=$(git -c core.useBuiltinFSMonitor=false diff --shortstat 2>/dev/null)

  # Check for upstream (inspired by oh-my-posh fetch_upstream_icon)
  upstream=$(git -c core.useBuiltinFSMonitor=false rev-parse --abbrev-ref @{upstream} 2>/dev/null)

  # Check stash count (from oh-my-posh fetch_stash_count)
  stash_count=$(git -c core.useBuiltinFSMonitor=false stash list 2>/dev/null | wc -l | tr -d ' ')

  # Check if in a git worktree
  worktree_name=""
  if [ -f "$dir/.git" ] && grep -q "gitdir:" "$dir/.git" 2>/dev/null; then
    # We're in a worktree - extract the worktree name from the path
    worktree_name=$(basename "$dir")
  fi

  if [ -n "$diff_stats" ]; then
    lines_added=$(echo "$diff_stats" | sed -n 's/.* \([0-9]*\) insertion.*/\1/p')
    lines_removed=$(echo "$diff_stats" | sed -n 's/.* \([0-9]*\) deletion.*/\1/p')
    [ -z "$lines_added" ] && lines_added=0
    [ -z "$lines_removed" ] && lines_removed=0
  else
    lines_added=0
    lines_removed=0
  fi
else
  branch=''
  upstream=''
  stash_count=0
  worktree_name=''
  lines_added=0
  lines_removed=0
fi

# Detect language versions (from oh-my-posh language segments)
lang_info=""
if cd "$dir" 2>/dev/null; then
  # Node.js
  if [ -f "package.json" ]; then
    node_version=$(node --version 2>/dev/null | sed 's/v//')
    [ -n "$node_version" ] && lang_info="${lang_info}node:${node_version} "
  fi

  # Python
  if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
    python_version=$(python3 --version 2>/dev/null | awk '{print $2}')
    [ -n "$python_version" ] && lang_info="${lang_info}py:${python_version} "
  fi

  # Ruby
  if [ -f "Gemfile" ]; then
    ruby_version=$(ruby --version 2>/dev/null | awk '{print $2}')
    [ -n "$ruby_version" ] && lang_info="${lang_info}rb:${ruby_version} "
  fi

  # Java
  if [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
    java_version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
    [ -n "$java_version" ] && lang_info="${lang_info}java:${java_version} "
  fi

  # Go
  if [ -f "go.mod" ]; then
    go_version=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
    [ -n "$go_version" ] && lang_info="${lang_info}go:${go_version} "
  fi
fi

# Context window calculation
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
  current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
  size=$(echo "$input" | jq '.context_window.context_window_size')
  remaining=$((100 - (current * 100 / size)))

  if [ "$remaining" -gt 50 ]; then
    ctx_color='\033[92m'  # Green
  elif [ "$remaining" -gt 20 ]; then
    ctx_color='\033[93m'  # Yellow
  else
    ctx_color='\033[91m'  # Red
  fi
  ctx="${remaining}%"
else
  ctx=''
  ctx_color=''
fi

# Format session time as human-readable
if [ "$duration_ms" != "0" ] && [ "$duration_ms" != "null" ]; then
  total_sec=$((duration_ms / 1000))
  hours=$((total_sec / 3600))
  minutes=$(((total_sec % 3600) / 60))
  seconds=$((total_sec % 60))

  if [ "$hours" -gt 0 ]; then
    session_time="${hours}h ${minutes}m"
  elif [ "$minutes" -gt 0 ]; then
    session_time="${minutes}m ${seconds}s"
  else
    session_time="${seconds}s"
  fi
else
  session_time=''
fi

# Format tokens (k for thousands)
format_tokens() {
  local tokens=$1
  if [ "$tokens" -ge 1000 ]; then
    awk -v t="$tokens" 'BEGIN {printf "%.1fk", t/1000}'
  else
    echo "$tokens"
  fi
}

input_fmt=$(format_tokens "$total_input")
output_fmt=$(format_tokens "$total_output")

# ============================================================
# LINE 1: Repo/Code (cool blues)
# ============================================================
line1=$(printf '\033[94m%s\033[0m' "$dir_display")

if [ -n "$branch" ]; then
  line1="$line1 $(printf '\033[2m│\033[0m \033[96m%s\033[0m' "$branch")"

  # Add stash count if present (from oh-my-posh)
  if [ "$stash_count" != "0" ]; then
    line1="$line1 $(printf '\033[93m(stash:%s)\033[0m' "$stash_count")"
  fi

  # Add worktree indicator if in a worktree
  if [ -n "$worktree_name" ]; then
    line1="$line1 $(printf '\033[95m⎇ %s\033[0m' "$worktree_name")"
  fi
fi

if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ]; then
  line1="$line1 $(printf '\033[2m│\033[0m \033[92m+%s\033[0m \033[91m-%s\033[0m' "$lines_added" "$lines_removed")"
fi

# ============================================================
# LINE 2: Context/Session (warm complementary) + languages
# ============================================================
line2=$(printf '\033[37m%s\033[0m' "$model")

# Add language info if present (from oh-my-posh language segments)
if [ -n "$lang_info" ]; then
  line2="$line2 $(printf '\033[2m│\033[0m \033[35m%s\033[0m' "$(echo "$lang_info" | sed 's/ $//')")"
fi

if [ -n "$session_time" ]; then
  line2="$line2 $(printf '\033[2m│\033[0m \033[33m%s\033[0m' "$session_time")"
fi

if [ -n "$ctx" ]; then
  line2="$line2 $(printf '\033[2m│\033[0m %b%s\033[0m' "$ctx_color" "$ctx")"
fi

if [ "$total_input" != "0" ] || [ "$total_output" != "0" ]; then
  # Both dark blue (34)
  line2="$line2 $(printf '\033[2m│\033[0m \033[34m↓%s in\033[0m \033[2m/\033[0m \033[34m↑%s out\033[0m' "$input_fmt" "$output_fmt")"
fi

# Output with blank line separator
printf '%b\n\n%b' "$line1" "$line2"
