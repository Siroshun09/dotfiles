#!/bin/sh
# Claude Code status line.
#
# Layout (single line, default):
#   <dir> (<branch>) [<model>·<effort>] ctx:N%  [5h:<reset>:N% 7d:<reset>:N%]  $<cost>
#
# Layout (two lines, when CLAUDE_STATUSLINE_MULTILINE is set non-empty):
#   <dir> (<branch>) [<model>·<effort>]
#   ctx:N%  [5h:<reset>:N% 7d:<reset>:N%]  $<cost>
#
# Notes:
#   * rate_limits (5h / 7d) are sent only for Claude.ai Pro/Max subscribers,
#     after the first API response. They are absent on usage-based / Enterprise
#     plans, where the session cost ($) stands in as the usage signal.
#   * effort is absent when the current model does not support it.
#   * ctx% / rate% are threshold-colored: green <70, yellow 70-89, red 90+.
#
# Portable across macOS / Linux: POSIX sh + jq + git, no absolute paths.

input=$(cat)
get() { printf '%s' "$input" | jq -r "$1"; }

dir=$(get '.workspace.current_dir // .cwd // ""')
model=$(get '.model.display_name // ""')
effort=$(get '.effort.level // empty')
ctx=$(get '.context_window.used_percentage // empty')
five=$(get '.rate_limits.five_hour.used_percentage // empty')
week=$(get '.rate_limits.seven_day.used_percentage // empty')
five_reset=$(get '.rate_limits.five_hour.resets_at // empty')
week_reset=$(get '.rate_limits.seven_day.resets_at // empty')
cost=$(get '.cost.total_cost_usd // 0')

# Real ESC byte so the rest of the script can concatenate plain strings.
esc=$(printf '\033')
DIM="${esc}[90m"; YEL="${esc}[33m"; BLU="${esc}[34m"
GRN="${esc}[32m"; YLW="${esc}[33m"; RED="${esc}[31m"; RST="${esc}[0m"

# Threshold color for a 0-100 value.
pct_color() {
  v=${1%.*}
  if   [ "${v:-0}" -ge 90 ] 2>/dev/null; then printf '%s' "$RED"
  elif [ "${v:-0}" -ge 70 ] 2>/dev/null; then printf '%s' "$YLW"
  else printf '%s' "$GRN"; fi
}

# Remaining time until a Unix-epoch reset, compactly formatted (e.g. 2h30m, 3d4h).
fmt_remaining() {
  rem=$(( $1 - $(date +%s) ))
  [ "$rem" -lt 0 ] && rem=0
  d=$(( rem / 86400 )); h=$(( rem % 86400 / 3600 )); m=$(( rem % 3600 / 60 ))
  if   [ "$d" -gt 0 ]; then printf '%dd%dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '%dh%dm' "$h" "$m"
  else printf '%dm' "$m"; fi
}

# Abbreviate the home directory to ~.
case "$dir" in
  "$HOME")   disp_dir="~" ;;
  "$HOME"/*) disp_dir="~${dir#"$HOME"}" ;;
  *)         disp_dir="$dir" ;;
esac

# Git branch (silently ignore non-repos / detached HEAD).
branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null)

# Line 1: directory / branch
line1="${YEL}${disp_dir}${RST}"
[ -n "$branch" ] && line1="$line1 ${BLU}(${branch})${RST}"

# Line 2: model · effort / context window / rate limits / session cost.
line2=""

# model · effort
if [ -n "$model" ]; then
  [ -n "$effort" ] && label="${model}·${effort}" || label="$model"
  line2="line2 ${DIM}[${label}]${RST}"
fi

# context window usage
if [ -n "$ctx" ]; then
  line2="$line2 $(pct_color "$ctx")ctx:$(printf '%.0f' "$ctx")%${RST}"
fi

# rate limits (Pro/Max only) — show time remaining until reset, then usage %;
# color reflects how much of the limit is consumed.
[ -n "$five_reset" ] && line2="$line2 $(pct_color "$five")5h:$(fmt_remaining "$five_reset"):$(printf '%.0f' "$five")%${RST}"
[ -n "$week_reset" ] && line2="$line2 $(pct_color "$week")7d:$(fmt_remaining "$week_reset"):$(printf '%.0f' "$week")%${RST}"

# session cost
line2="$line2 ${DIM}\$$(printf '%.2f' "$cost")${RST}"

# Trim the single leading space accumulated on line 2.
line2=${line2# }

# When CLAUDE_STATUSLINE_MULTILINE is set (non-empty), print on two lines;
# otherwise keep the original single-line layout.
if [ -n "$CLAUDE_STATUSLINE_MULTILINE" ]; then
  printf '%s\n%s' "$line1" "$line2"
else
  printf '%s %s' "$line1" "$line2"
fi
