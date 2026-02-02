#!/usr/bin/env bash
set -euo pipefail

# Exports UID/GID based on your current host user, and ensures a local .env exists.
# Usage:
#   ./scripts/export_env.sh
#   docker compose build
#   docker compose up -d
#
# You can also just run:
#   UID=$(id -u) C_GID=$(id -g) USERNAME=${USERNAME:-dev} docker compose up --build

USERNAME="${USERNAME:-dev}"
C_UID="$(id -u)"
C_GID="$(id -g)"

cat > .env <<EOF
USERNAME=${USERNAME}
C_UID=${C_UID}
C_GID=${C_GID}
EOF

echo "Wrote .env with USERNAME=${USERNAME} C_UID=${C_UID} C_GID=${C_GID}"
