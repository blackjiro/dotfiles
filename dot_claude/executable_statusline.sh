#!/bin/bash
input=$(cat)

# Cache settings
CACHE_FILE="/tmp/claude_rate_limit_cache.json"
CACHE_TTL=60  # seconds

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

# Rate limit from OAuth API with caching
get_rate_limit() {
  local now=$(date +%s)

  # Check cache
  if [ -f "$CACHE_FILE" ]; then
    local cache_time=$(jq -r '.timestamp // 0' "$CACHE_FILE" 2>/dev/null)
    local age=$((now - cache_time))
    if [ "$age" -lt "$CACHE_TTL" ]; then
      jq -r '.data' "$CACHE_FILE" 2>/dev/null
      return
    fi
  fi

  # Fetch from API
  local creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
  local token=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // empty')

  if [ -z "$token" ]; then
    echo ""
    return
  fi

  local response=$(curl -s --max-time 2 \
    -H "Authorization: Bearer $token" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

  local util=$(echo "$response" | jq -r '.five_hour.utilization // empty')
  local reset=$(echo "$response" | jq -r '.five_hour.resets_at // empty')

  if [ -n "$util" ] && [ -n "$reset" ]; then
    # Convert UTC to local time (HH:MM format)
    local utc_time="${reset%%.*}"
    local epoch=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$utc_time" "+%s" 2>/dev/null)
    local reset_local=$(date -r "$epoch" "+%H:%M" 2>/dev/null || echo "")
    local result="${util%.*}%"
    [ -n "$reset_local" ] && result="${result}(${reset_local})"

    # Save to cache
    echo "{\"timestamp\":$now,\"data\":\"$result\"}" > "$CACHE_FILE"
    echo "$result"
  else
    echo ""
  fi
}

# Build statusline
DIR=$(basename "$(get_dir)")
MODEL=$(get_model)
CONTEXT=$(get_context_percent)
COST=$(get_cost)
ADDED=$(get_lines_added)
REMOVED=$(get_lines_removed)
RATE=$(get_rate_limit)

# Output with ANSI colors
printf "\033[34m%s\033[0m" "$DIR"
printf " \033[33m[%s]\033[0m" "$MODEL"
printf " \033[36m%d%%\033[0m" "$CONTEXT"
printf " \033[32m\$%.2f\033[0m" "$COST"
printf " \033[90m+%d/-%d\033[0m" "$ADDED" "$REMOVED"
[ -n "$RATE" ] && printf " \033[35m%s\033[0m" "$RATE"
