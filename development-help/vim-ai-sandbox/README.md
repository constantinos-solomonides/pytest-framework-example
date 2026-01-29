# Vim AI Sandbox (Docker)

Goal: a Vim-based dev sandbox with AI integration **without exposing your host filesystem by default**.
Persistence uses **bind-mounted directories** (`./persist/...`), not Docker volumes.

## Contents
- `vim/` — Vim container image
- `ollama` sidecar — local LLM runtime
- `litellm` sidecar — OpenAI-compatible proxy (optional but enabled by default)
- `open-webui` sidecar — web UI for chat (optional but enabled by default)
- `persist/` — host directories that persist across container deletion

## Quick start

### 1) Set environment variables (UID/GID)
Create `.env` from the example:

```bash
cp .env.example .env
```

Edit `.env` (recommended) OR export variables in shell:

```bash
export LOCAL_UID="$(id -u)"
export LOCAL_GID="$(id -g)"
export LOCAL_USER="$(id -un | tr -cd '[:alnum:]_-')"
```

### 2) Build + start
```bash
docker compose up -d --build
```

### 3) Pull a coding model into Ollama
Pick a model you want, then:

```bash
docker compose exec ollama ollama pull qwen2.5-coder:7b
# or: codellama:7b-instruct, deepseek-coder:6.7b, etc.
```

### 4) Enter the Vim sandbox
```bash
docker compose exec vim bash
vim
```

## How this avoids exposing your host filesystem
Only these host directories are mounted:
- `./persist/home`   -> `/home/$LOCAL_USER`
- `./persist/workspace` -> `/workspace`
- `./persist/ollama` -> Ollama model cache
- `./persist/open-webui` -> UI state

So:
- Your real `$HOME` is not mounted.
- Your project directories are not mounted unless you copy them into `./persist/workspace`.

### Bringing code in/out (explicit)
Copy in from host:
```bash
rsync -a --delete /path/to/your/project ./persist/workspace/project
```

Copy out to host:
```bash
rsync -a --delete ./persist/workspace/project /path/to/your/project
```

## Using AI in Vim
Leader is `\`.

- `\aa` Ask AI (uses selected text as context if you're in Visual mode)
- `\ar` Rewrite selection in-place (Visual mode)
- `\ae` Explain selection in a scratch buffer
- `\ah` Help page

Also available:
- `:AIAsk ...`
- `:'<,'>AIRewrite ...`
- `:'<,'>AIExplain`

## Switching providers
Default is `AI_PROVIDER=ollama` and `AI_BASE_URL=http://ollama:11434`.

If you want OpenAI-compatible chat completions instead:
- set `AI_PROVIDER=openai_compat`
- set `OPENAI_COMPAT_BASE_URL` (default points to `litellm`)
- set `OPENAI_COMPAT_API_KEY` (required by many servers; LiteLLM accepts empty for local unless you configure master_key)

### Using LiteLLM as a stable API surface
- LiteLLM exposes `/v1/chat/completions` on port 4000.
- It is configured to talk to Ollama as `local-ollama` by default (`litellm/config.yaml`).
- You can add remote providers in `litellm/config.yaml` and provide keys in `.env`.

## Notes / failure modes
- If AI returns empty output, check the provider is reachable:
  ```bash
  docker compose exec vim bash -lc 'echo hello | /usr/local/bin/ai_chat.sh'
  ```
- If Ollama is slow on first token, that’s normal on first run; model load can take time.
- If plugin installation is blocked (corporate proxy etc.), Vim still works; AI scripts do not depend on plugins.

## Tear down
```bash
docker compose down
```
This stops containers but keeps `./persist/...` intact.

To wipe everything:
```bash
rm -rf ./persist
```

## Security posture (what this does / does not do)
- This setup keeps AI inside the Docker network. If you add remote provider keys, requests may go out to the internet via LiteLLM.
- This does not prevent you from manually copying sensitive files into `./persist/workspace`.
- If you need stronger isolation (e.g., read-only workspace), you can mount `./persist/workspace` as `:ro` and use a separate writable scratch dir.
