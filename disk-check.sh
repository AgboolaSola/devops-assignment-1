#!/usr/bin/env bash
# disk-check.sh - warns when disk usage reaches a threshold
# Usage: ./disk-check.sh <threshold 1-100> [path]
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/disk-check.log"
mkdir -p "$LOG_DIR"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

usage() {
  echo "Usage: $0 <threshold 1-100> [path]" >&2
}

THRESHOLD="${1:-}"
TARGET_PATH="${2:-/}"

log "Started disk-check.sh (threshold=$THRESHOLD, path=$TARGET_PATH)"

# Check 1: a threshold was given
if [[ -z "$THRESHOLD" ]]; then
  echo "Error: threshold is required." >&2
  usage
  log "Invalid input: missing threshold"
  exit 2
fi

# Check 2: the threshold is a whole number
if [[ ! "$THRESHOLD" =~ ^[0-9]+$ ]]; then
  echo "Error: threshold must be a whole number, got '$THRESHOLD'." >&2
  usage
  log "Invalid input: non-numeric threshold '$THRESHOLD'"
  exit 2
fi


# Check 3: the threshold is between 1 and 100
if [[ "$THRESHOLD" -lt 1 || "$THRESHOLD" -gt 100 ]]; then
  echo "Error: threshold must be between 1 and 100, got '$THRESHOLD'." >&2
  usage
  log "Invalid input: threshold '$THRESHOLD' is outside 1-100"
  exit 2
fi

# Check 4: does the path exist
if [[ ! -e "$TARGET_PATH" ]]; then
  echo "Error: path '$TARGET_PATH' does not exist." >&2
  usage
  log "Invalid input: path '$TARGET_PATH' doesn't exist"
  exit 2
fi
echo "Threshold OK: $THRESHOLD%"