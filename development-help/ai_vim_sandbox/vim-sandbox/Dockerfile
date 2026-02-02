FROM debian:bookworm-slim

ARG UID=1000
ARG GID=1000
ARG USERNAME=dev

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    vim \
    python3 \
    python3-httpx \
    python3-jinja2 \
    python3-venv \
    python3-pip \
    ripgrep \
    less \
    tzdata \
  && rm -rf /var/lib/apt/lists/*

# Create a user matching host UID/GID
RUN groupadd -g ${GID} ${USERNAME} \
  && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME}

# Install vim-plug (plugin manager)
RUN curl -fsSL https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
  -o /usr/share/vim/vimfiles/autoload/plug.vim

COPY vimrc /etc/vim/vimrc.local
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER ${USERNAME}
WORKDIR /workspace

# Pre-install plugins (best-effort). This will run once at build time.
RUN vim +'silent! PlugInstall --sync' +qa || true

ENTRYPOINT ["/entrypoint.sh"]
CMD ["vim"]
