#!/usr/bin/env bash
#
# Deploy mengirim.id landing page ke production server.
#
# Usage:
#   ./deploy/deploy.sh              # build + upload
#   ./deploy/deploy.sh --skip-build # langsung upload tanpa rebuild
#   ./deploy/deploy.sh --dry-run    # preview perubahan, gak upload beneran

set -euo pipefail

# --- Config ---------------------------------------------------------------
REMOTE_USER="${REMOTE_USER:-www-data}"
REMOTE_HOST="${REMOTE_HOST:-43.157.210.19}"
REMOTE_PATH="${REMOTE_PATH:-/var/www/mengirim.id}"
SSH_PORT="${SSH_PORT:-22}"
LOCAL_DIST="${LOCAL_DIST:-dist}"

# --- Colors ---------------------------------------------------------------
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  YELLOW='\033[0;33m'
  RED='\033[0;31m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  GREEN='' BLUE='' YELLOW='' RED='' BOLD='' RESET=''
fi

log() { echo -e "${BLUE}▶${RESET} $*"; }
ok()  { echo -e "${GREEN}✓${RESET} $*"; }
warn(){ echo -e "${YELLOW}!${RESET} $*"; }
err() { echo -e "${RED}✗${RESET} $*" >&2; }

# --- Parse args -----------------------------------------------------------
SKIP_BUILD=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --skip-build) SKIP_BUILD=1 ;;
    --dry-run)    DRY_RUN=1 ;;
    -h|--help)
      sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) err "Unknown arg: $arg"; exit 1 ;;
  esac
done

# --- Move to project root --------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BOLD}mengirim.id — deploy${RESET}"
echo "  target: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
echo "  source: ${PROJECT_ROOT}/${LOCAL_DIST}/"
[ "$DRY_RUN" -eq 1 ] && echo "  mode:   DRY RUN (no changes)"
echo

# --- Preflight ------------------------------------------------------------
command -v rsync >/dev/null 2>&1 || { err "rsync tidak terpasang."; exit 1; }
command -v ssh >/dev/null 2>&1   || { err "ssh tidak terpasang."; exit 1; }

# --- Build ----------------------------------------------------------------
if [ "$SKIP_BUILD" -eq 0 ]; then
  log "Build production..."
  npm run build
  ok "Build selesai."
else
  warn "Skip build (--skip-build). Pakai dist/ yang sudah ada."
fi

if [ ! -d "$LOCAL_DIST" ] || [ -z "$(ls -A "$LOCAL_DIST" 2>/dev/null)" ]; then
  err "Folder $LOCAL_DIST/ kosong atau tidak ada. Jalankan 'npm run build' dulu."
  exit 1
fi

# --- SSH connectivity check -----------------------------------------------
log "Test koneksi SSH ke ${REMOTE_USER}@${REMOTE_HOST}:${SSH_PORT}..."
if ! ssh -p "$SSH_PORT" -o ConnectTimeout=10 -o BatchMode=yes \
    "${REMOTE_USER}@${REMOTE_HOST}" "echo ok" >/dev/null 2>&1; then
  err "Koneksi SSH gagal. Pastikan:"
  err "  - SSH key kamu sudah terdaftar di ~${REMOTE_USER}/.ssh/authorized_keys"
  err "  - User ${REMOTE_USER} punya shell login (cek /etc/passwd)"
  err "  - Port ${SSH_PORT} terbuka dari IP kamu"
  exit 1
fi
ok "Koneksi SSH oke."

# --- Pastikan folder target ada & writable --------------------------------
log "Cek folder target di server..."
ssh -p "$SSH_PORT" "${REMOTE_USER}@${REMOTE_HOST}" \
  "mkdir -p '${REMOTE_PATH}' && test -w '${REMOTE_PATH}'" || {
    err "Folder ${REMOTE_PATH} tidak bisa ditulis oleh ${REMOTE_USER}."
    err "Fix di server: sudo chown -R ${REMOTE_USER}:${REMOTE_USER} ${REMOTE_PATH}"
    exit 1
  }
ok "Folder target siap."

# --- Rsync ----------------------------------------------------------------
RSYNC_OPTS=(
  -avz
  --delete
  --human-readable
  --progress
  --exclude='.DS_Store'
  --exclude='*.map'
  -e "ssh -p ${SSH_PORT}"
)

# rsync >= 3.1 support --info=progress2 (progress bar satu baris, lebih rapi)
RSYNC_VER="$(rsync --version 2>/dev/null | awk 'NR==1 {print $3}')"
RSYNC_MAJOR="${RSYNC_VER%%.*}"
if [ -n "$RSYNC_MAJOR" ] && [ "$RSYNC_MAJOR" -ge 3 ] 2>/dev/null; then
  RSYNC_OPTS=("${RSYNC_OPTS[@]/--progress/--info=progress2}")
fi
[ "$DRY_RUN" -eq 1 ] && RSYNC_OPTS+=(--dry-run)

log "Upload ke server..."
rsync "${RSYNC_OPTS[@]}" "${LOCAL_DIST}/" \
  "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"

if [ "$DRY_RUN" -eq 1 ]; then
  warn "DRY RUN selesai. Tidak ada perubahan di server."
  exit 0
fi

ok "Upload selesai."

# --- Post-deploy (opsional: reload nginx) ---------------------------------
# Uncomment kalau mau reload nginx otomatis dan user punya sudo nopasswd:
# log "Reload nginx..."
# ssh -p "$SSH_PORT" "${REMOTE_USER}@${REMOTE_HOST}" \
#   "sudo nginx -t && sudo systemctl reload nginx" && ok "nginx reloaded."

echo
ok "${BOLD}Deploy sukses!${RESET} 🚀"
echo "   → https://mengirim.id"
