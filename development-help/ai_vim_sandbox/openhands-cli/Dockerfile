FROM python:3.12-slim

# Basic tooling you’ll want in an interactive agent container
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash ca-certificates curl git jq \
 && rm -rf /var/lib/apt/lists/*

# Install OpenHands CLI
RUN pip install --no-cache-dir openhands-ai

# Workspace mounted here
WORKDIR /workspace

# Keep all OpenHands state under persist/ (bind-mounted)
ENV HOME=/persist/openhands-cli

# Default to bash so you can log in and run commands manually
ENTRYPOINT ["/bin/bash"]
