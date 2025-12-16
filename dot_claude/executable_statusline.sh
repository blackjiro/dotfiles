#!/bin/bash
input=$(cat)

# Helper functions
get_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_model() { echo "$input" | jq -r '.model.display_name'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd // 0'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added // 0'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed // 0'; }
get_context_percent() {
  local size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
  local usage=$(echo "$input" | jq -r '
    (.context_window.current_usage.input_tokens // 0) +
    (.context_window.current_usage.cache_creation_input_tokens // 0) +
    (.context_window.current_usage.cache_read_input_tokens // 0)
  ')
  if [ "$size" -gt 0 ]; then
    echo $((usage * 100 / size))
  else
    echo 0
  fi
}

# Build statusline
DIR=$(basename "$(get_dir)")
MODEL=$(get_model)
CONTEXT=$(get_context_percent)
COST=$(get_cost)
ADDED=$(get_lines_added)
REMOVED=$(get_lines_removed)

# Output with ANSI colors
printf "\033[34m%s\033[0m" "$DIR"
printf " \033[33m[%s]\033[0m" "$MODEL"
printf " \033[36m%d%%\033[0m" "$CONTEXT"
printf " \033[32m\$%.2f\033[0m" "$COST"
printf " \033[90m+%d/-%d\033[0m" "$ADDED" "$REMOVED"
