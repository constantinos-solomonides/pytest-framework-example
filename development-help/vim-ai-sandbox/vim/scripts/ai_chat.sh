#!/usr/bin/env bash
set -euo pipefail
source /usr/local/bin/ai_common.sh

# Output only the assistant text on stdout.
if [[ "$AI_PROVIDER" == "ollama" ]]; then
  # Ollama native API
  # https://github.com/ollama/ollama/blob/main/docs/api.md (schema may evolve; we keep it minimal)
  curl -sS "${AI_BASE_URL%/}/api/generate" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg model "$AI_MODEL" --arg prompt "$PROMPT" \
          '{model:$model, prompt:$prompt, stream:false}')" \
  | jq -r '.response // empty'
  exit 0
fi

if [[ "$AI_PROVIDER" == "openai_compat" ]]; then
  # OpenAI-compatible Chat Completions
  # Expected endpoint: /v1/chat/completions
  curl -sS "${OPENAI_COMPAT_BASE_URL%/}/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${OPENAI_COMPAT_API_KEY}" \
    -d "$(jq -n \
      --arg model "$AI_MODEL" \
      --arg content "$PROMPT" \
      '{
        model: $model,
        messages: [
          {role:"system", content:"You are a concise, accurate coding assistant."},
          {role:"user", content:$content}
        ],
        temperature: 0.2
      }')" \
  | jq -r '.choices[0].message.content // empty'
  exit 0
fi

err "unknown AI_PROVIDER: $AI_PROVIDER (expected: ollama|openai_compat)"
exit 2
