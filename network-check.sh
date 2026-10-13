#!/usr/bin/env bash
# network-check.sh - checks if a host is reachable, and optionally a TCP port
# Usage: ./network-check.sh <hostname-or-ip> [port]
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/network-check.log"
mkdir -p "$LOG_DIR"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

usage() {
  echo "Usage: $0 <hostname-or-ip> [port 1-65535]" >&2
}

HOST="${1:-}"
PORT="${2:-}"

log "Started network-check.sh (host=$HOST, port=${PORT:-none})"

# Check 1: a host was given
if [[ -z "$HOST" ]]; then
  echo "Error: host is required." >&2
  usage
  log "Invalid input: missing host"
  exit 2
fi

# Check 2: the host only contains valid characters
if [[ ! "$HOST" =~ ^[A-Za-z0-9.:-]+$ ]]; then
  echo "Error: '$HOST' is not a valid hostname or IP address." >&2
  usage
  log "Invalid input: bad host '$HOST'"
  exit 2
fi

# Check 3: if a port was given, it is a whole number
if [[ -n "$PORT"  && !  "$PORT" =~ ^[0-9]+$ ]]; then
 echo "Error: port must be a whole number, got '$PORT'." >&2 
 usage
 log "Invalid input: $PORT is not a valid whole number"
 exit 2
fi 
# Check 4: if a port was given, it is between 1 and 65535
if [[ -n "$PORT"  && ("$PORT" -lt 1 || "$PORT" -gt 65535 ) ]]; then
 echo "Error: port must be between 1 and 65535, got '$PORT'." >&2
 usage
 log "Invalid input: $PORT is not between 1 and 65535"
 exit 2
fi 

RESOLVED_IP="$(getent ahosts "$HOST" | head -n 1 | awk '{print $1}')"

if [[ -z "$RESOLVED_IP" ]]; then
  echo "Error: could not resolve '$HOST'." >&2
  log "Failed: could not resolve '$HOST'"
  exit 1
fi
echo "Resolved $HOST to $RESOLVED_IP"
log "Resolved $HOST to $RESOLVED_IP"

# Basic connectivity check
STATUS=0

if ping -c 1 -W 2 "$HOST" > /dev/null 2>&1; then
  echo "Connectivity: $HOST is reachable"
  log "Connectivity OK: $HOST replied to ping"
else
  echo "Connectivity: $HOST did not reply to ping"
  log "Connectivity failed: $HOST did not reply to ping"
  STATUS=1
fi
echo "Network interfaces:"
ip -brief address
log "Displayed network interface information"
exit "$STATUS"

