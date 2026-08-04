#!/bin/bash

# =============================================================
# setup.sh - First time project initialization
# Usage: bash setup.sh
# =============================================================

set -euo pipefail

CLAUDE_MD="CLAUDE.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[SETUP]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

prompt_required() {
  local var_name="$1" prompt_text="$2" input
  while true; do
    read -rp "$prompt_text: " input
    [ -n "$input" ] && { eval "$var_name=\"$input\""; break; } || warn "Cannot be empty."
  done
}

echo ""
echo "========================================"
echo "  Project Setup"
echo "========================================"
echo ""

prompt_required PROJECT_NAME "Project name (e.g. my-app)"

# Write project name to CLAUDE.md
sed -i "s|{PROJECT_NAME}|$PROJECT_NAME|g" "$CLAUDE_MD"
sed -i "s|{SETUP_DATE}|$TIMESTAMP|g" "$CLAUDE_MD"

log "Project name set: $PROJECT_NAME"

mkdir -p code
log "code/ ready. Put your source in there, in whatever stack you're using."

echo ""
log "Setup complete."
log "Next steps:"
echo "  1. Write docs/SRS.md and docs/PRD.md."
echo "  2. Run: bash sync.sh (syncs docs/SRS.md Stack section into CLAUDE.md)"
echo "  3. Start working task by task, Plan Mode first for anything non-trivial."
echo "  4. See SCRATCHPAD.md for open work, DECISION-LOG.md for the history."
echo ""
