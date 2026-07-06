#!/bin/bash

# =============================================================
# deploy.sh - Interactive deploy wizard for EC2
# Usage: sudo bash deploy.sh
# =============================================================

set -euo pipefail

# ── Config ───────────────────────────────────────────────────
CONFIG_FILE=".deploy.conf"
LOG_FILE="deploy.log"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── Logger ───────────────────────────────────────────────────
log()    { local msg="[$(date '+%H:%M:%S')] [INFO]  $1"; echo -e "${GREEN}${msg}${NC}"; echo "$msg" >> "$LOG_FILE"; }
warn()   { local msg="[$(date '+%H:%M:%S')] [WARN]  $1"; echo -e "${YELLOW}${msg}${NC}"; echo "$msg" >> "$LOG_FILE"; }
error()  { local msg="[$(date '+%H:%M:%S')] [ERROR] $1"; echo -e "${RED}${msg}${NC}"; echo "$msg" >> "$LOG_FILE"; }
section(){ echo ""; echo -e "${CYAN}======================================${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}======================================${NC}"; echo ""; }

# ── Root check ───────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
  error "Run as root: sudo bash deploy.sh"
  exit 1
fi

# ── Load / save config ────────────────────────────────────────
load_config() {
  [ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE" && log "Config loaded from $CONFIG_FILE"
}

save_config() {
  cat > "$CONFIG_FILE" <<EOF
PROJECT_DIR="${PROJECT_DIR:-}"
APP_TYPE="${APP_TYPE:-}"
APP_PORT="${APP_PORT:-}"
HEALTH_CHECK_URL="${HEALTH_CHECK_URL:-}"
DB_CONNECTION="${DB_CONNECTION:-}"
DB_HOST="${DB_HOST:-}"
DB_PORT="${DB_PORT:-}"
DB_DATABASE="${DB_DATABASE:-}"
DB_USERNAME="${DB_USERNAME:-}"
S3_PROVIDER="${S3_PROVIDER:-}"
S3_BUCKET="${S3_BUCKET:-}"
S3_REGION="${S3_REGION:-}"
S3_ENDPOINT="${S3_ENDPOINT:-}"
CF_TUNNEL_URL="${CF_TUNNEL_URL:-}"
CUSTOM_COMMAND="${CUSTOM_COMMAND:-}"
NODE_COMMAND="${NODE_COMMAND:-}"
EOF
  log "Config saved."
}

# ── Input helpers ─────────────────────────────────────────────
prompt_required() {
  local var_name="$1" prompt_text="$2" current_val="${!1:-}" input
  while true; do
    if [ -n "$current_val" ]; then
      read -rp "$prompt_text [$current_val]: " input
      input="${input:-$current_val}"
    else
      read -rp "$prompt_text: " input
    fi
    [ -n "$input" ] && { eval "$var_name=\"$input\""; break; } || warn "Cannot be empty."
  done
}

prompt_secret() {
  local var_name="$1" prompt_text="$2" input
  while true; do
    read -rsp "$prompt_text: " input; echo ""
    [ -n "$input" ] && { eval "$var_name=\"$input\""; break; } || warn "Cannot be empty."
  done
}

prompt_select() {
  local var_name="$1" prompt_text="$2"; shift 2
  local options=("$@")
  echo "$prompt_text"
  for i in "${!options[@]}"; do
    echo "  $((i+1)). ${options[$i]}"
  done
  while true; do
    read -rp "Choice [1-${#options[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
      eval "$var_name=\"${options[$((choice-1))]}\""
      break
    else
      warn "Invalid choice."
    fi
  done
}

# ── Backup .env ───────────────────────────────────────────────
backup_env() {
  local env_file="$PROJECT_DIR/.env"
  if [ -f "$env_file" ]; then
    cp "$env_file" "$env_file.backup.$TIMESTAMP"
    log "Backed up .env to .env.backup.$TIMESTAMP"
  fi
}

# ── Write to .env ─────────────────────────────────────────────
write_env() {
  local key="$1" value="$2" env_file="$PROJECT_DIR/.env"
  if grep -q "^${key}=" "$env_file" 2>/dev/null; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$env_file"
  else
    echo "${key}=${value}" >> "$env_file"
  fi
}

# ── Systemd helpers ───────────────────────────────────────────
reload_service() {
  local svc="$1"
  systemctl daemon-reload
  if systemctl is-enabled "$svc" &>/dev/null; then
    systemctl restart "$svc"
  else
    systemctl enable --now "$svc"
  fi
  log "Service $svc started."
}

# =============================================================
# SECTION 1: Project dir
# =============================================================
setup_project_dir() {
  section "Project Directory"
  prompt_required PROJECT_DIR "Absolute path to project directory"
  if [ ! -d "$PROJECT_DIR" ]; then
    error "Directory not found: $PROJECT_DIR"
    exit 1
  fi
  log "Project dir: $PROJECT_DIR"
}

# =============================================================
# SECTION 2: App type
# =============================================================
setup_app_type() {
  section "App Type"
  prompt_select APP_TYPE "Select app type:" \
    "Laravel only (php-fpm + nginx)" \
    "Laravel + Vite (dev/staging)" \
    "Laravel + Node queue worker" \
    "Laravel + Horizon" \
    "Node/Bun only" \
    "Custom command"

  prompt_required APP_PORT "App port (e.g. 8000 for Laravel, 3000 for Node)"

  if [ "$APP_TYPE" = "Custom command" ]; then
    prompt_required CUSTOM_COMMAND "Enter run command"
  fi

  if [ "$APP_TYPE" = "Laravel + Node queue worker" ]; then
    NODE_COMMAND="php artisan queue:work --sleep=3 --tries=3"
    log "Queue worker command: $NODE_COMMAND"
  fi

  log "App type: $APP_TYPE"
}

generate_laravel_service() {
  cat > /etc/systemd/system/laravel-app.service <<EOF
[Unit]
Description=Laravel App (php-fpm)
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/sbin/php-fpm8.2 -F
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
  reload_service laravel-app
}

generate_horizon_service() {
  cat > /etc/systemd/system/laravel-horizon.service <<EOF
[Unit]
Description=Laravel Horizon
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/bin/php artisan horizon
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
  reload_service laravel-horizon
}

generate_queue_service() {
  cat > /etc/systemd/system/laravel-queue.service <<EOF
[Unit]
Description=Laravel Queue Worker
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/bin/php artisan queue:work --sleep=3 --tries=3 --max-time=3600
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
  reload_service laravel-queue
}

generate_node_service() {
  local cmd="${CUSTOM_COMMAND:-bun run start}"
  cat > /etc/systemd/system/node-app.service <<EOF
[Unit]
Description=Node/Bun App
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$PROJECT_DIR
ExecStart=$cmd
Restart=always
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF
  reload_service node-app
}

generate_vite_service() {
  cat > /etc/systemd/system/laravel-vite.service <<EOF
[Unit]
Description=Vite Dev Server
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/bin/npx vite --host 0.0.0.0 --port 5173
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
  reload_service laravel-vite
}

deploy_services() {
  section "Deploying Services"
  case "$APP_TYPE" in
    "Laravel only (php-fpm + nginx)")
      generate_laravel_service ;;
    "Laravel + Vite (dev/staging)")
      generate_laravel_service
      generate_vite_service ;;
    "Laravel + Node queue worker")
      generate_laravel_service
      generate_queue_service ;;
    "Laravel + Horizon")
      generate_laravel_service
      generate_horizon_service ;;
    "Node/Bun only")
      generate_node_service ;;
    "Custom command")
      CUSTOM_COMMAND_ESCAPED=$(systemd-escape "$CUSTOM_COMMAND")
      cat > /etc/systemd/system/custom-app.service <<EOF
[Unit]
Description=Custom App
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$PROJECT_DIR
ExecStart=$CUSTOM_COMMAND
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
      reload_service custom-app ;;
  esac
}

# =============================================================
# SECTION 3: Database
# =============================================================
test_db_connection() {
  local driver="$1" host="$2" port="$3" db="$4" user="$5" pass="$6"
  if [ "$driver" = "mysql" ]; then
    MYSQL_PWD="$pass" mysql -h "$host" -P "$port" -u "$user" -e "USE $db;" 2>/dev/null
  else
    PGPASSWORD="$pass" psql -h "$host" -p "$port" -U "$user" -d "$db" -c "SELECT 1;" 2>/dev/null
  fi
}

setup_database() {
  section "Database"
  prompt_select DB_CONNECTION "Database driver:" "pgsql" "mysql"

  local default_port="5432"
  [ "$DB_CONNECTION" = "mysql" ] && default_port="3306"

  while true; do
    prompt_required DB_HOST "DB host (RDS endpoint or localhost)"
    DB_PORT="${DB_PORT:-$default_port}"
    prompt_required DB_PORT "DB port"
    prompt_required DB_DATABASE "DB name"
    prompt_required DB_USERNAME "DB user"
    prompt_secret DB_PASSWORD "DB password"

    log "Testing DB connection..."
    if test_db_connection "$DB_CONNECTION" "$DB_HOST" "$DB_PORT" "$DB_DATABASE" "$DB_USERNAME" "$DB_PASSWORD"; then
      log "DB connection OK."
      break
    else
      error "Connection failed. Check credentials and try again."
    fi
  done

  write_env "DB_CONNECTION" "$DB_CONNECTION"
  write_env "DB_HOST" "$DB_HOST"
  write_env "DB_PORT" "$DB_PORT"
  write_env "DB_DATABASE" "$DB_DATABASE"
  write_env "DB_USERNAME" "$DB_USERNAME"
  write_env "DB_PASSWORD" "$DB_PASSWORD"
  log "DB config written to .env"
}

# =============================================================
# SECTION 4: S3 Storage
# =============================================================
test_s3_connection() {
  if [ "$S3_PROVIDER" = "AWS S3" ]; then
    AWS_ACCESS_KEY_ID="$S3_KEY" AWS_SECRET_ACCESS_KEY="$S3_SECRET" \
      aws s3 ls "s3://$S3_BUCKET" --region "$S3_REGION" &>/dev/null
  elif [ "$S3_PROVIDER" = "Cloudflare R2" ]; then
    AWS_ACCESS_KEY_ID="$S3_KEY" AWS_SECRET_ACCESS_KEY="$S3_SECRET" \
      aws s3 ls "s3://$S3_BUCKET" --endpoint-url "$S3_ENDPOINT" &>/dev/null
  else
    # Azure: basic curl check on container endpoint
    curl -sf "${S3_ENDPOINT}/${S3_BUCKET}?restype=container" \
      -H "x-ms-version: 2020-10-02" &>/dev/null
  fi
}

setup_s3() {
  section "S3 / Object Storage"
  prompt_select S3_PROVIDER "Select provider:" "AWS S3" "Cloudflare R2" "Azure Blob"

  while true; do
    case "$S3_PROVIDER" in
      "AWS S3")
        prompt_required S3_BUCKET  "Bucket name"
        prompt_required S3_REGION  "Region (e.g. ap-southeast-1)"
        prompt_required S3_KEY     "AWS Access Key ID"
        prompt_secret   S3_SECRET  "AWS Secret Access Key"
        S3_ENDPOINT="https://s3.${S3_REGION}.amazonaws.com"
        ;;
      "Cloudflare R2")
        prompt_required S3_BUCKET   "Bucket name"
        prompt_required S3_ENDPOINT "R2 endpoint URL (https://<account>.r2.cloudflarestorage.com)"
        prompt_required S3_KEY      "R2 Access Key ID"
        prompt_secret   S3_SECRET   "R2 Secret Access Key"
        S3_REGION="auto"
        ;;
      "Azure Blob")
        prompt_required S3_BUCKET   "Container name"
        prompt_required S3_ENDPOINT "Azure Blob endpoint (https://<account>.blob.core.windows.net)"
        prompt_required S3_KEY      "Storage account name"
        prompt_secret   S3_SECRET   "Storage account key"
        S3_REGION=""
        ;;
    esac

    log "Testing storage connection..."
    if test_s3_connection; then
      log "Storage connection OK."
      break
    else
      error "Storage connection failed. Check credentials and try again."
    fi
  done

  # Write to .env (Laravel filesystem config)
  write_env "FILESYSTEM_DISK" "s3"
  write_env "AWS_ACCESS_KEY_ID" "$S3_KEY"
  write_env "AWS_SECRET_ACCESS_KEY" "$S3_SECRET"
  write_env "AWS_DEFAULT_REGION" "${S3_REGION:-auto}"
  write_env "AWS_BUCKET" "$S3_BUCKET"
  write_env "AWS_ENDPOINT" "$S3_ENDPOINT"
  write_env "AWS_USE_PATH_STYLE_ENDPOINT" "true"
  log "Storage config written to .env"
}

# =============================================================
# SECTION 5: Cloudflare Tunnel
# =============================================================
install_cloudflared() {
  if command -v cloudflared &>/dev/null; then
    log "cloudflared already installed: $(cloudflared --version)"
    return
  fi
  log "Installing cloudflared..."
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
    | gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg
  echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/cloudflared.list
  apt-get update -qq
  apt-get install -y cloudflared
  log "cloudflared installed."
}

setup_cloudflare_tunnel() {
  section "Cloudflare Tunnel"

  while true; do
    prompt_required CF_TUNNEL_URL "Tunnel URL (e.g. https://abc.trycloudflare.com or your named tunnel URL)"
    if [[ "$CF_TUNNEL_URL" =~ ^https?:// ]]; then
      break
    else
      warn "Must start with https://"
    fi
  done

  install_cloudflared

  cat > /etc/systemd/system/cloudflared-tunnel.service <<EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=nobody
ExecStart=/usr/local/bin/cloudflared tunnel --url http://localhost:${APP_PORT} --no-autoupdate
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  reload_service cloudflared-tunnel
  log "Tunnel running -> $CF_TUNNEL_URL"
}

# =============================================================
# SECTION 6: Health check
# =============================================================
run_health_check() {
  section "Health Check"
  prompt_required HEALTH_CHECK_URL "Health check URL (e.g. http://localhost:${APP_PORT}/api/health)"

  log "Waiting 5s for services to stabilize..."
  sleep 5

  local retries=5 delay=5 i
  for ((i=1; i<=retries; i++)); do
    log "Health check attempt $i/$retries..."
    if curl -sf --max-time 10 "$HEALTH_CHECK_URL" &>/dev/null; then
      log "Health check PASSED."
      return 0
    fi
    warn "Not responding yet. Retrying in ${delay}s..."
    sleep "$delay"
  done

  error "Health check FAILED after $retries attempts."
  error "Check logs: journalctl -u <service> -n 50"
  return 1
}

# =============================================================
# SECTION 7: Summary
# =============================================================
print_summary() {
  section "Deploy Summary"
  echo "  App type     : $APP_TYPE"
  echo "  Project dir  : $PROJECT_DIR"
  echo "  DB           : $DB_CONNECTION://$DB_HOST:$DB_PORT/$DB_DATABASE"
  echo "  Storage      : $S3_PROVIDER (bucket: $S3_BUCKET)"
  echo "  Tunnel       : $CF_TUNNEL_URL"
  echo "  Health check : $HEALTH_CHECK_URL"
  echo ""
  log "Deploy log: $LOG_FILE"
}

# =============================================================
# MAIN
# =============================================================
main() {
  echo ""
  echo "========================================"
  echo "  Deploy Wizard"
  echo "========================================"
  echo "  Log: $LOG_FILE"
  echo "========================================"
  echo ""

  echo "[$(date)] Deploy started" >> "$LOG_FILE"

  load_config
  setup_project_dir
  backup_env
  setup_app_type
  setup_database
  setup_s3
  setup_cloudflare_tunnel
  save_config
  deploy_services
  run_health_check
  print_summary

  echo "[$(date)] Deploy finished" >> "$LOG_FILE"
}

main
