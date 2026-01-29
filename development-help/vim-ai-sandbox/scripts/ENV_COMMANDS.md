# Host helper commands

## Export env vars for UID/GID and user
```bash
export LOCAL_UID="$(id -u)"
export LOCAL_GID="$(id -g)"
export LOCAL_USER="$(id -un | tr -cd '[:alnum:]_-')"
```

## One-liner: create .env automatically (Linux/macOS)
```bash
cat > .env <<'EOF'
LOCAL_UID=$(id -u)
LOCAL_GID=$(id -g)
LOCAL_USER=$(id -un | tr -cd '[:alnum:]_-')
AI_PROVIDER=ollama
AI_MODEL=qwen2.5-coder:7b
AI_BASE_URL=http://ollama:11434
OPENAI_COMPAT_BASE_URL=http://litellm:4000
OPENAI_COMPAT_API_KEY=
EOF
```

## Start
```bash
docker compose up -d --build
```
