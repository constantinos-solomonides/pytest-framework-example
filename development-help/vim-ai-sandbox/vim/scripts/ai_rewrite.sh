#!/usr/bin/env bash
set -euo pipefail
source /usr/local/bin/ai_common.sh

INSTR="${1:-Rewrite the input with improved clarity and correctness while preserving meaning. Output only the rewritten text.}"

PROMPT_FINAL=$(jq -n --arg instr "$INSTR" --arg input "$PROMPT" \
  '"Instruction:\n\($instr)\n\nInput:\n\($input)\n\nOutput:"' -r)

echo "$PROMPT_FINAL" | /usr/local/bin/ai_chat.sh
