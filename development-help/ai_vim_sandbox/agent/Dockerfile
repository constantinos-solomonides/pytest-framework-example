FROM python:3.12-slim

ARG UID=1000
ARG GID=1000
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

RUN groupadd -g ${GID} ${USERNAME} \
  && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME}

WORKDIR /opt/agent
COPY requirements.txt /opt/agent/requirements.txt
RUN pip install --no-cache-dir -r /opt/agent/requirements.txt

COPY agent_loop.py /opt/agent/agent_loop.py

USER ${USERNAME}
WORKDIR /workspace

CMD ["bash"]
