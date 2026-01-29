#!/usr/bin/env bash
set -euo pipefail
source /usr/local/bin/ai_common.sh

PROMPT_FINAL=$(jq -n --arg input "$PROMPT" \
  '"Explain the following code or text. Be precise and avoid speculation.\n\n---\n\($input)\n---\n"' -r)

echo "$PROMPT_FINAL" | /usr/local/bin/ai_chat.sh
