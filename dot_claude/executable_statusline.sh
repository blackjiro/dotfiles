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

  # Try to get token from multiple sources
  local token=""

  # 1. Try Anthropic OAuth (keychain)
  local creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
  if [ -n "$creds" ]; then
    token=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // empty')
  fi

  # 2. Try environment variable (Vertex AI or other setups)
  if [ -z "$token" ] && [ -n "$ANTHROPIC_API_KEY" ]; then
    token="$ANTHROPIC_API_KEY"
  fi

  if [ -z "$token" ]; then
    echo ""
    return
  fi

  # Try Anthropic API first (works with OAuth tokens)
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
DIR=$(basename "$(get_dir)" 2>/dev/null)
MODEL=$(get_model 2>/dev/null)
CONTEXT=$(get_context_percent 2>/dev/null)
COST=$(get_cost 2>/dev/null)
ADDED=$(get_lines_added 2>/dev/null)
REMOVED=$(get_lines_removed 2>/dev/null)
RATE=$(get_rate_limit 2>/dev/null)

# Provide defaults for missing values
DIR="${DIR:-unknown}"
MODEL="${MODEL:-unknown}"
CONTEXT="${CONTEXT:-0}"
COST="${COST:-0}"
ADDED="${ADDED:-0}"
REMOVED="${REMOVED:-0}"

# Output with ANSI colors
printf "\033[34m%s\033[0m" "$DIR"
[ "$MODEL" != "unknown" ] && printf " \033[33m[%s]\033[0m" "$MODEL"
[ "$CONTEXT" != "0" ] && printf " | \033[36m %d%%\033[0m" "$CONTEXT"
[ "$COST" != "0" ] && printf " | \033[32m\$%.2f\033[0m" "$COST"
[ "$ADDED" != "0" ] || [ "$REMOVED" != "0" ] && printf " | \033[90m +%d/-%d\033[0m" "$ADDED" "$REMOVED"
[ -n "$RATE" ] && printf " | \033[35m %s\033[0m" "$RATE"

exit 0
