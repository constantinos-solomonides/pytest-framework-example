# Vim + AI sandbox (Docker)

Goal: provide a *bounded* dev environment with Vim and AI assistance, without exposing your whole host filesystem.

Key properties:
- Uses **bind-mounted directories** (not Docker volumes) for persistence.
- Only mounts **explicit directories** under `./persist/` into containers.
- Runs containers as a **non-root user** matching your host `UID/GID`.

Services:
- `vim-sandbox`: Vim with an Ollama-backed Vim plugin.
- `ollama`: local LLM server (HTTP API).
- `ai-agent`: optional iterative agent loop runner (human approval gate).

## Quick start

```bash
# 1) Set USERNAME/UID/GID based on your host user
./scripts/export_env.sh

# 2) Build + start everything
docker compose up -d --build

# 3) (Optional) pull a model
docker compose exec -it ollama ollama pull qwen2.5-coder:7b
```

Open Vim:

```bash
./scripts/run_vim.sh
```

## Persistence and isolation

Persistent directories (all under `./persist/`):
- `persist/workspace`  -> `/workspace` inside containers (your *only* shared project area)
- `persist/home`       -> `/home/$USERNAME` (shell history, configs)
- `persist/vim`        -> `/home/$USERNAME/.vim` (plugin cache)
- `persist/ollama`     -> `/root/.ollama` inside the Ollama container (models)

This approach avoids mounting your entire host home directory into containers.

## Vim AI usage

This environment installs the **vim-ollama** plugin. citeturn0search0

Configured in `vim-sandbox/vimrc`:
- Leader key: `\`
- `\oc` : Ollama completion (`:OllamaComplete`)
- Visual select + `\or` : rewrite selection (`:OllamaRewrite`)

If you change the compose service name or port, update `g:ollama_host`.

Ollama API base URL defaults to `http://ollama:11434/api` and the chat endpoint is `POST /api/chat`. citeturn0search2turn0search8

## Agentic iteration inside the container

The `ai-agent` container includes a minimal agent loop runner:

```bash
docker compose exec -it agent bash
python /opt/agent/agent_loop.py --goal "make tests pass" --success "ALL TESTS PASSED"
```

Notes:
- The runner prompts you to approve every command/write.
- Logs are kept in `.agent/` under the workspace.

## Security notes

- Only mount what you intend the AI to see.
- Avoid mounting SSH keys into the container unless you understand the risk.
- If you need network isolation, add compose network rules (not included here).

## Troubleshooting

- Verify Ollama is reachable from Vim container:
  ```bash
  docker compose exec -it vim curl -s http://ollama:11434/api/tags | head
  ```

- If you want to disable host port exposure, remove the `ports:` line from `ollama`.
  The Vim container can still reach it via the internal compose network.

## References

- Ollama API docs: base URL and `/api/chat`. citeturn0search2turn0search8
- vim-ollama plugin repository. citeturn0search0
