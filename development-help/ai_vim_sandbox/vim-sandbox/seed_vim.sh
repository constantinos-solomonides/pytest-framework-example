#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
VIM_DIR="${HOME}/.vim"
AUTOLOAD_DIR="${VIM_DIR}/autoload"
PLUG_FILE="${AUTOLOAD_DIR}/plug.vim"

# Prefer local vimrc if present; fall back to system-local
USER_VIMRC="${HOME}/.vimrc"
SYSTEM_VIMRC="/etc/vim/vimrc.local"

# Sentinel file: existence == already seeded
SENTINEL_FILE="${VIM_DIR}/.seeded"

# Marker block for idempotent vimrc edits
MARKER_BEGIN="\" >>> ai-sandbox seed BEGIN"
MARKER_END="\" <<< ai-sandbox seed END"

# --- Guard: already seeded ---
if [ -f "${SENTINEL_FILE}" ]; then
  exit 0
fi

# --- Ensure vim-plug exists ---
mkdir -p "${AUTOLOAD_DIR}"

if [ ! -f "${PLUG_FILE}" ]; then
  curl -fsSL https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    -o "${PLUG_FILE}"
fi
chmod 0644 "${PLUG_FILE}"

# --- Choose target vimrc to edit ---
TARGET_VIMRC="${USER_VIMRC}"
if [ ! -f "${TARGET_VIMRC}" ]; then
  # If user vimrc doesn't exist, seed into system-local one.
  TARGET_VIMRC="${SYSTEM_VIMRC}"
fi

# --- Ensure vimrc contains required plug bootstrap/config ---
# We only append our block if the marker isn't present.
if ! grep -Fq "${MARKER_BEGIN}" "${TARGET_VIMRC}" 2>/dev/null; then
  cat >> "${TARGET_VIMRC}" <<'EOF'

" >>> ai-sandbox seed BEGIN
" Ensure ~/.vim is on runtimepath (bind-mount safe)
set runtimepath^=~/.vim
set runtimepath+=~/.vim/after
let &packpath = &runtimepath

" If your vimrc already defines mapleader, keep yours; otherwise set it here.
if !exists("mapleader")
  let mapleader="\\"
endif

" vim-plug bootstrap (expects ~/.vim/autoload/plug.vim)
if exists('*plug#begin')
  " If you already have a plugin section elsewhere, you may remove the plugins below
  " and keep only the PlugInstall step in this script.
  call plug#begin('~/.vim/plugged')

  " Minimal plugins (example)
  Plug 'gergap/vim-ollama'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

  call plug#end()
endif
" <<< ai-sandbox seed END
EOF
fi

# --- Install plugins (headless) ---
# -E  : improved Ex mode
# -s  : silent
# +qa : quit all after install
# Use --not-a-term to avoid TTY assumptions if available; vim on Debian supports -es.
vim -Es +'silent! PlugInstall --sync' +qa || true

# --- Mark as seeded ---
touch "${SENTINEL_FILE}"

exit 0
