#!/usr/bin/env bash
set -euo pipefail

# Ensure WORKDIR exists and is writable
WORKDIR="${WORKDIR:-/workspace}"
mkdir -p "${WORKDIR}"

exec "$@"
