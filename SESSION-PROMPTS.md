#!/bin/bash

# =============================================================
# sync.sh - Sync stack info from SRS/PRD into CLAUDE.md
# Usage: bash sync.sh
# Run after PM session updates docs/SRS.md or docs/PRD.md
# =============================================================

set -euo pipefail

SRS_FILE="docs/SRS.md"
PRD_FILE="docs/PRD.md"
CLAUDE_MD=".claude/CLAUDE.md"
LOG_FILE="logs/sync.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()   { local msg="[$TIMESTAMP] $1"; echo -e "${GREEN}[SYNC]${NC} $1"; echo "$msg" >> "$LOG_FILE"; }
warn()  { local msg="[$TIMESTAMP] WARN: $1"; echo -e "${YELLOW}[WARN]${NC} $1"; echo "$msg" >> "$LOG_FILE"; }
error() { local msg="[$TIMESTAMP] ERROR: $1"; echo -e "${RED}[ERROR]${NC} $1"; echo "$msg" >> "$LOG_FILE"; }

mkdir -p logs

# Check required files
for f in "$SRS_FILE" "$PRD_FILE" "$CLAUDE_MD"; do
  if [ ! -f "$f" ]; then
    error "Missing: $f"
    exit 1
  fi
done

# Parse ## Stack section from SRS.md
parse_stack() {
  local file="$1"
  awk '/^## Stack/{found=1; next} found && /^## /{exit} found{print}' "$file" \
    | grep -E '^\s*-' \
    | sed 's/^\s*-\s*//'
}

STACK_LINES=$(parse_stack "$SRS_FILE")

if [ -z "$STACK_LINES" ]; then
  warn "No ## Stack section found in $SRS_FILE. CLAUDE.md stack not updated."
  exit 0
fi

log "Parsed stack from $SRS_FILE:"
echo "$STACK_LINES" | while read -r line; do
  echo "  - $line"
done

# Build replacement block
STACK_BLOCK="## Stack (auto-synced from SRS.md on $TIMESTAMP)"$'\n'
while IFS= read -r line; do
  STACK_BLOCK+="- $line"$'\n'
done <<< "$STACK_LINES"

# Replace block between markers in CLAUDE.md
perl -i -0pe "s/<!-- STACK_START -->.*?<!-- STACK_END -->/<!-- STACK_START -->\n${STACK_BLOCK}<!-- STACK_END -->/s" "$CLAUDE_MD"

log "CLAUDE.md updated."
log "Sync log: $LOG_FILE"
