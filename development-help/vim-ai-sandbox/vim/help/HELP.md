# Vim AI Sandbox — Help

## Key bindings
Leader is `\` (backslash).

- `\aa` — Ask AI (prompts you; if you are in Visual mode it also includes selected text as context)
- `\ar` — Rewrite selection in-place (Visual mode)
- `\ae` — Explain selection into a scratch buffer
- `\ah` — Open this help page
- `\n` — Toggle NERDTree

## Commands
- `:AIAsk [question]`
- `:'<,'>AIRewrite [optional rewrite instruction]`
- `:'<,'>AIExplain`

## Provider switching
The Vim commands call scripts that route to either:
- `AI_PROVIDER=ollama` (native Ollama API), or
- `AI_PROVIDER=openai_compat` (OpenAI-style `/v1/chat/completions`)

These are controlled by container environment variables (see README).
