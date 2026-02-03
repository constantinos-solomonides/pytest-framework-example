#!/usr/bin/env bash
set -euo pipefail

# Run seed each start (idempotent). Do not block normal startup.
if command -v seed_vim.sh >/dev/null 2>&1; then
  seed_vim.sh || true
fi

exec "$@"
