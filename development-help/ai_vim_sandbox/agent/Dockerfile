FROM python:3.12-slim

ARG C_UID=1000
ARG C_GID=1000
ARG USERNAME=dev

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    bash \
    build-essential \
    ripgrep \
  && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${C_GID} ${USERNAME} \
  && useradd -m -u ${C_UID} -g ${C_GID} -s /bin/bash ${USERNAME}

WORKDIR /opt/agent
COPY requirements.txt /opt/agent/requirements.txt
RUN pip install --no-cache-dir -r /opt/agent/requirements.txt

COPY agent_loop.py /opt/agent/agent_loop.py

USER ${USERNAME}
WORKDIR /workspace

CMD ["bash"]
