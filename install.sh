#!/usr/bin/env bash
# =============================================================================
#  install.sh — Install Neovim + this config for ANY user on Ubuntu 24 LTS
#
#  Usage:
#    As root:        sudo bash install.sh
#    As normal user: bash install.sh
#    Install for another user from root: sudo bash install.sh --user john
#
#  What it does:
#    1. Installs Neovim (latest stable) system-wide to /usr/local/bin
#    2. Installs system deps (ripgrep, fd, node, etc.)
#    3. Clones this config into the TARGET user's ~/.config/nvim
#    4. Sets correct ownership so the user can pull/edit the config
# =============================================================================
set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'
info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERR]${NC}   $*"; exit 1; }

# ── Parse args ────────────────────────────────────────────────────────────────
TARGET_USER="${SUDO_USER:-$USER}"   # default: whoever ran sudo (or current user)
REPO_URL="https://github.com/YOUR_USERNAME/nvim-config.git"
NVIM_CONFIG_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) TARGET_USER="$2"; shift 2 ;;
    --repo) REPO_URL="$2";    shift 2 ;;
    *) error "Unknown argument: $1" ;;
  esac
done

# Resolve target user's home directory
TARGET_HOME=$(eval echo "~${TARGET_USER}")
NVIM_CONFIG_DIR="${TARGET_HOME}/.config/nvim"
NVIM_DATA_DIR="${TARGET_HOME}/.local/share/nvim"

info "Installing for user: ${TARGET_USER}"
info "Home directory:       ${TARGET_HOME}"
info "Config directory:     ${NVIM_CONFIG_DIR}"
echo ""

# ── Ensure running as root for system installs ───────────────────────────────
if [[ $EUID -ne 0 ]]; then
  warn "Not running as root. System packages will be skipped."
  warn "Run with sudo for a full install: sudo bash install.sh"
  SKIP_SYSTEM=1
else
  SKIP_SYSTEM=0
fi

# ── 1. System packages ────────────────────────────────────────────────────────
if [[ $SKIP_SYSTEM -eq 0 ]]; then
  info "Installing system dependencies..."
  apt-get update -qq
  apt-get install -y -qq \
    git curl unzip tar gzip wget \
    ripgrep fd-find \
    build-essential \
    python3 python3-pip python3-venv \
    shellcheck \
    xclip xdotool \
    fzf \
    tmux

  # Node.js 20 LTS (required for prettierd, markdown-preview, etc.)
  if ! command -v node &>/dev/null || [[ $(node -v | cut -d. -f1 | tr -d 'v') -lt 18 ]]; then
    info "Installing Node.js 20 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
  else
    ok "Node.js already installed: $(node -v)"
  fi

  # prettierd + stylua via npm/cargo
  npm install -g prettierd prettier 2>/dev/null || warn "prettierd install failed (non-fatal)"

  # fd is installed as fdfind on Ubuntu — symlink it
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    ln -sf "$(which fdfind)" /usr/local/bin/fd
    ok "Symlinked fdfind → fd"
  fi

  ok "System packages installed"
fi

# ── 2. Neovim (latest stable AppImage) ───────────────────────────────────────
install_neovim() {
  info "Installing Neovim (latest stable)..."
  local NVIM_VER
  NVIM_VER=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest \
    | grep '"tag_name"' | cut -d '"' -f4)

  if [[ -z "$NVIM_VER" ]]; then
    error "Could not fetch Neovim version. Check internet connection."
  fi

  info "Downloading Neovim ${NVIM_VER}..."
  local TMP=$(mktemp -d)
  curl -L --progress-bar \
    "https://github.com/neovim/neovim/releases/download/${NVIM_VER}/nvim-linux-x86_64.tar.gz" \
    -o "${TMP}/nvim.tar.gz"

  tar -xzf "${TMP}/nvim.tar.gz" -C "${TMP}"
  rm -rf /opt/nvim-linux-x86_64
  mv "${TMP}/nvim-linux-x86_64" /opt/
  ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
  rm -rf "${TMP}"
  ok "Neovim ${NVIM_VER} installed → /usr/local/bin/nvim"
}

if [[ $SKIP_SYSTEM -eq 0 ]]; then
  if ! command -v nvim &>/dev/null; then
    install_neovim
  else
    CURRENT=$(nvim --version | head -1 | grep -oP '[\d.]+' | head -1)
    info "Neovim already installed: v${CURRENT}"
    read -rp "  Re-install latest? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] && install_neovim || ok "Keeping v${CURRENT}"
  fi
else
  command -v nvim &>/dev/null || error "Neovim not found. Run with sudo to install it."
fi

echo ""
info "Neovim: $(nvim --version | head -1)"

# ── 3. Clone / update config for target user ─────────────────────────────────
clone_or_update() {
  local dir="$1"

  if [[ -d "${dir}/.git" ]]; then
    info "Config exists at ${dir}, pulling latest..."
    run_as_user git -C "${dir}" pull --ff-only || warn "git pull failed (local changes?)"
    ok "Config updated"
  elif [[ -d "${dir}" ]] && [[ -n "$(ls -A ${dir})" ]]; then
    warn "${dir} exists but is NOT a git repo."
    read -rp "  Overwrite it? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      run_as_user rm -rf "${dir}"
      run_as_user git clone "${REPO_URL}" "${dir}"
      ok "Config cloned"
    else
      error "Aborted. Remove ${dir} manually and re-run."
    fi
  else
    info "Cloning config into ${dir}..."
    run_as_user mkdir -p "${TARGET_HOME}/.config"
    run_as_user git clone "${REPO_URL}" "${dir}"
    ok "Config cloned"
  fi
}

# Helper: run a command as the target user
run_as_user() {
  if [[ $EUID -eq 0 && "$TARGET_USER" != "root" ]]; then
    su -c "$*" - "${TARGET_USER}"
  else
    "$@"
  fi
}

clone_or_update "${NVIM_CONFIG_DIR}"

# ── 4. Ensure correct ownership ───────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
  chown -R "${TARGET_USER}:${TARGET_USER}" "${NVIM_CONFIG_DIR}"
  run_as_user mkdir -p "${NVIM_DATA_DIR}"
  chown -R "${TARGET_USER}:${TARGET_USER}" "${NVIM_DATA_DIR}"
  ok "Ownership set to ${TARGET_USER}"
fi

# ── 5. Python tools (as target user) ─────────────────────────────────────────
info "Installing Python formatters..."
run_as_user pip3 install --user --quiet black isort flake8 2>/dev/null \
  || warn "pip install failed (non-fatal)"

# ── 6. Shell convenience aliases ─────────────────────────────────────────────
ALIAS_BLOCK='
# Neovim aliases
alias vi="nvim"
alias vim="nvim"
alias v="nvim"
alias vz="nvim ~/.config/nvim"          # open config
alias vr="nvim --clean"                  # open without config (debug)
'

add_aliases() {
  local rc="$1"
  if [[ -f "$rc" ]] && ! grep -q "# Neovim aliases" "$rc"; then
    echo "$ALIAS_BLOCK" >> "$rc"
    ok "Aliases added to $rc"
  fi
}

run_as_user bash -c "
  add_aliases() {
    local rc=\"\$1\"
    if [[ -f \"\$rc\" ]] && ! grep -q '# Neovim aliases' \"\$rc\"; then
      echo '$ALIAS_BLOCK' >> \"\$rc\"
    fi
  }
  add_aliases ~/.bashrc
  add_aliases ~/.zshrc 2>/dev/null || true
"

# ── 7. tmux clipboard support ─────────────────────────────────────────────────
TMUX_CONF="${TARGET_HOME}/.tmux.conf"
TMUX_BLOCK='
# OSC52 clipboard support (required for Neovim cross-SSH yank)
set -s set-clipboard on
set -as terminal-features ",*:clipboard"
set -g default-terminal "screen-256color"
set -as terminal-overrides ",*:Tc"
'

if [[ ! -f "$TMUX_CONF" ]] || ! grep -q "set-clipboard" "$TMUX_CONF"; then
  run_as_user bash -c "echo '$TMUX_BLOCK' >> '$TMUX_CONF'"
  ok "tmux OSC52 config added to ${TMUX_CONF}"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Install complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "  User:         ${TARGET_USER}"
echo "  Config:       ${NVIM_CONFIG_DIR}"
echo "  Neovim:       $(nvim --version | head -1)"
echo ""
echo "  Next steps:"
echo "  1. Log in as ${TARGET_USER} (or: su - ${TARGET_USER})"
echo "  2. Run: nvim"
echo "  3. Wait for lazy.nvim to install all plugins (~1 min)"
echo "  4. Run :MasonUpdate to install LSP servers"
echo ""
echo -e "${YELLOW}  Clipboard tip:${NC}"
echo "  If copying from VPS to local doesn't work, check your terminal:"
echo "  - iTerm2: Prefs → General → Selection → Allow clipboard access"
echo "  - tmux:   source ~/.tmux.conf  (or restart tmux)"
echo ""
