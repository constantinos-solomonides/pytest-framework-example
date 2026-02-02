#!/usr/bin/env bash
set -euo pipefail

# Opens an interactive Vim session inside the container.
# Usage:
#   ./scripts/run_vim.sh
docker compose exec -it vim vim
