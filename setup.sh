#!/bin/bash

# =============================================================
# setup.sh - First time project initialization
# Usage: bash setup.sh
# =============================================================

set -euo pipefail

CLAUDE_MD=".claude/CLAUDE.md"
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

# Optional: init Laravel in code/
echo ""
read -rp "Install fresh Laravel 11 in code/? (y/n): " install_laravel
if [[ "$install_laravel" =~ ^[Yy]$ ]]; then
  if command -v composer &>/dev/null; then
    log "Running composer create-project..."
    composer create-project laravel/laravel code --prefer-dist
    log "Laravel installed in code/"
  else
    warn "composer not found. Install Laravel manually: composer create-project laravel/laravel code"
  fi
else
  log "Skipping Laravel install. Put your code in code/"
fi

echo ""
log "Setup complete."
log "Next steps:"
echo "  1. Open PM session: use .claude/agents/PM.md as system prompt"
echo "  2. Write SRS and PRD in docs/"
echo "  3. Run: bash sync.sh"
echo "  4. Open DEV session: use .claude/agents/DEV.md as system prompt"
echo ""
