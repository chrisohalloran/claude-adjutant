#!/bin/bash
# Runs a claude -p command with a lockfile to prevent overlapping executions.
# Usage: run-with-lock.sh <lock-name> <claude args...>
# Example: run-with-lock.sh heartbeat -p "$(cat heartbeat.md)" --model sonnet

set -euo pipefail

LOCK_NAME="${1:?Usage: run-with-lock.sh <lock-name> <claude args...>}"
shift

LOCK_DIR="$HOME/adjutant/locks"
LOCK_FILE="$LOCK_DIR/$LOCK_NAME.lock"
LOG_FILE="$HOME/adjutant/logs/$LOCK_NAME.log"
USAGE_LOG="$HOME/adjutant/logs/usage.jsonl"

mkdir -p "$LOCK_DIR" "$(dirname "$LOG_FILE")"

# Check for stale lock (older than 30 minutes)
if [ -f "$LOCK_FILE" ]; then
  LOCK_AGE=$(( $(date +%s) - $(stat -f %m "$LOCK_FILE") ))
  if [ "$LOCK_AGE" -gt 1800 ]; then
    echo "$(date -Iseconds) Removing stale lock ($LOCK_AGE seconds old)" >> "$LOG_FILE"
    rm -f "$LOCK_FILE"
  else
    echo "$(date -Iseconds) Skipped — already running ($LOCK_AGE seconds)" >> "$LOG_FILE"
    exit 0
  fi
fi

# Acquire lock
echo $$ > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# Ensure we're in the adjutant directory for CLAUDE.md and config discovery
cd "$HOME/adjutant"

# Unset API key so claude uses Max/Pro subscription instead of API credits
unset ANTHROPIC_API_KEY

# Run claude and capture output
echo "$(date -Iseconds) Starting $LOCK_NAME" >> "$LOG_FILE"

OUTPUT=$(claude "$@" --output-format json 2>>"$LOG_FILE") || true

# Extract usage data and append to usage log
if [ -n "$OUTPUT" ]; then
  echo "$OUTPUT" | jq -c '{
    timestamp: now | todate,
    job: "'"$LOCK_NAME"'",
    session_id: .session_id,
    cost_usd: .cost_usd,
    duration_ms: .duration_ms,
    num_turns: .num_turns
  } // empty' >> "$USAGE_LOG" 2>/dev/null || true
fi

echo "$(date -Iseconds) Finished $LOCK_NAME" >> "$LOG_FILE"
