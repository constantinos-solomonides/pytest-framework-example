FROM node:22-bookworm-slim

# ---- build args for UID/GID matching ----
ARG UID=1000
ARG GID=1000
ARG USERNAME=dev

# Create group/user that match host UID/GID
RUN groupadd -g ${GID} ${USERNAME} \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME}

# Useful tools (git is commonly needed; ca-certs for TLS)
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates bash \
 && rm -rf /var/lib/apt/lists/*

# Install Codex CLI (official npm package)
RUN npm install -g @openai/codex

# Workspace + codex config dir live under the non-root user
USER ${USERNAME}
WORKDIR /workspace

# Keep container alive; you will exec into it to run codex commands
CMD ["bash", "-lc", "sleep infinity"]
