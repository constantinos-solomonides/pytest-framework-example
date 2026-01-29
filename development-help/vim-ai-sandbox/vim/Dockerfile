FROM debian:bookworm-slim

ARG LOCAL_UID=1000
ARG LOCAL_GID=1000
ARG LOCAL_USER=dev

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim-nox \
    git \
    curl \
    ca-certificates \
    python3 \
    python3-venv \
    python3-pip \
    jq \
    ripgrep \
    less \
    openssh-client \
  && rm -rf /var/lib/apt/lists/*

# Create group/user matching host UID/GID
RUN groupadd -g ${LOCAL_GID} ${LOCAL_USER} \
 && useradd -m -u ${LOCAL_UID} -g ${LOCAL_GID} -s /bin/bash ${LOCAL_USER}

# Vim plugin manager (vim-plug)
RUN mkdir -p /usr/local/share/vim/site/autoload \
 && curl -fsSL https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    -o /usr/local/share/vim/site/autoload/plug.vim

# Provide scripts and vimrc
COPY --chmod=755 scripts/ /usr/local/bin/
COPY vimrc /etc/vim/vimrc.local
COPY help/ /usr/local/share/vim-ai-help/

# Ensure persistent home is compatible
RUN mkdir -p /workspace \
 && chown -R ${LOCAL_UID}:${LOCAL_GID} /workspace

USER ${LOCAL_USER}
WORKDIR /workspace

# Pre-create vim directories in HOME (will live on bind mount ./persist/home)
RUN mkdir -p ~/.vim ~/.vim/plugged ~/.cache

CMD ["bash"]
