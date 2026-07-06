#!/bin/bash

# =============================================================
# update.sh - Force update project from GitHub
# Usage: bash update.sh
# =============================================================

set -e

CONFIG_FILE=".update.conf"

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()    { echo -e "${GREEN}[UPDATE]${NC} $1"; }
warn()   { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()  { echo -e "${RED}[ERROR]${NC} $1"; }

# ── Load or create config ────────────────────────────────────
load_config() {
  if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    log "Config loaded from $CONFIG_FILE"
  fi
}

save_config() {
  cat > "$CONFIG_FILE" <<EOF
REPO_URL="$REPO_URL"
BRANCH="$BRANCH"
PROJECT_DIR="$PROJECT_DIR"
EOF
  log "Config saved to $CONFIG_FILE"
}

# ── Input with retry ─────────────────────────────────────────
prompt_required() {
  local var_name="$1"
  local prompt_text="$2"
  local current_val="${!var_name}"
  local input

  while true; do
    if [ -n "$current_val" ]; then
      read -rp "$prompt_text [$current_val]: " input
      input="${input:-$current_val}"
    else
      read -rp "$prompt_text: " input
    fi

    if [ -n "$input" ]; then
      eval "$var_name=\"$input\""
      break
    else
      warn "Value cannot be empty. Try again."
    fi
  done
}

# ── Validate git repo URL ─────────────────────────────────────
validate_repo_url() {
  local url="$1"
  if [[ "$url" =~ ^https?://.*\.git$ ]] || [[ "$url" =~ ^git@.*:.*\.git$ ]]; then
    return 0
  fi
  return 1
}

prompt_repo_url() {
  while true; do
    prompt_required REPO_URL "GitHub repo URL (https or ssh)"
    if validate_repo_url "$REPO_URL"; then
      break
    else
      warn "Invalid URL format. Example: https://github.com/user/repo.git"
    fi
  done
}

# ── Validate target directory ─────────────────────────────────
prompt_project_dir() {
  while true; do
    prompt_required PROJECT_DIR "Project directory (absolute path)"
    if [ -d "$PROJECT_DIR" ]; then
      log "Directory exists: $PROJECT_DIR"
      break
    else
      warn "Directory not found: $PROJECT_DIR"
      read -rp "Create it? (y/n): " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        mkdir -p "$PROJECT_DIR"
        log "Created: $PROJECT_DIR"
        break
      fi
    fi
  done
}

# ── Main update logic ─────────────────────────────────────────
do_update() {
  log "Starting update..."
  log "Repo   : $REPO_URL"
  log "Branch : $BRANCH"
  log "Dir    : $PROJECT_DIR"

  cd "$PROJECT_DIR"

  # Init git if not already
  if [ ! -d ".git" ]; then
    log "No .git found. Initializing and pulling..."
    git init
    git remote add origin "$REPO_URL"
    git fetch origin "$BRANCH"
    git reset --hard "origin/$BRANCH"
  else
    CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
    if [ "$CURRENT_REMOTE" != "$REPO_URL" ]; then
      warn "Remote mismatch. Updating remote to $REPO_URL"
      git remote set-url origin "$REPO_URL"
    fi

    log "Fetching latest from origin/$BRANCH..."
    git fetch origin "$BRANCH"

    log "Force resetting to origin/$BRANCH (local changes will be overwritten)..."
    git reset --hard "origin/$BRANCH"
    git clean -fd
  fi

  log "Update complete. HEAD is now:"
  git log --oneline -1
}

# ── Entry point ───────────────────────────────────────────────
main() {
  echo ""
  echo "========================================"
  echo "  Project Updater"
  echo "========================================"
  echo ""

  load_config

  prompt_repo_url
  prompt_required BRANCH "Branch to pull"
  prompt_project_dir

  echo ""
  read -rp "Confirm update? This will OVERWRITE local changes. (y/n): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    warn "Update cancelled."
    exit 0
  fi

  save_config
  echo ""
  do_update

  echo ""
  log "Done."
}

main
