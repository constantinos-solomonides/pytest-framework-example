FROM debian:bookworm-slim

ARG C_UID=1000
ARG C_GID=1000
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

# Copy seed script + entrypoint
COPY seed_vim.sh /usr/local/bin/seed_vim.sh
RUN chmod +x /usr/local/bin/seed_vim.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create a user matching host UID/GID
RUN groupadd -g ${C_GID} ${USERNAME} \
  && useradd -m -u ${C_UID} -g ${C_GID} -s /bin/bash ${USERNAME}

# Install vim-plug (plugin manager)
RUN mkdir -p /home/${USERNAME}/.vim/autoload \
 && curl -fsSL https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
     -o /home/${USERNAME}/.vim/autoload/plug.vim \
      && chown -R ${USERNAME}:${C_GID} /home/${USERNAME}/.vim


COPY vimrc /etc/vim/vimrc.local
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER ${USERNAME}
WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
CMD ["vim"]
