#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/system-info.log"
mkdir -p "$LOG_DIR"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log "Started system-info.sh"

echo "===== System Information ====="
echo "Hostname: $(hostname)"
echo "Current user: $(whoami)"
echo "Date/time: $(date)"
echo "OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
echo "Kernel version: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "CPU model:$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2)"
echo "CPU cores: $(nproc)"
echo "Memory:"
free -h
echo "Current working directory: $(pwd)"

log "Finished system-info.sh"
exit 0