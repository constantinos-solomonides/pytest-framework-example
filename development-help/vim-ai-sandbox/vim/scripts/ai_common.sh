#!/usr/bin/env bash
set -euo pipefail

# Common config
AI_PROVIDER="${AI_PROVIDER:-ollama}"              # ollama | openai_compat
AI_MODEL="${AI_MODEL:-qwen2.5-coder:7b}"
AI_BASE_URL="${AI_BASE_URL:-http://ollama:11434}"
OPENAI_COMPAT_BASE_URL="${OPENAI_COMPAT_BASE_URL:-http://litellm:4000}"
OPENAI_COMPAT_API_KEY="${OPENAI_COMPAT_API_KEY:-}"

# Read prompt from stdin
PROMPT="$(cat)"

err() { echo "ai: $*" >&2; }

require() {
  command -v "$1" >/dev/null 2>&1 || { err "missing dependency: $1"; exit 2; }
}

require curl
require jq

if [[ -z "${PROMPT// }" ]]; then
  err "empty prompt"
  exit 2
fi

