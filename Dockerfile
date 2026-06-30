FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:$PATH"

# System dependencies
RUN apt update && apt install -y \
    curl \
    git \
    ca-certificates \
    sudo \
    python3 \
    python3-venv \
    python3-pip \
    docker.io \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Create workspace
WORKDIR /opt

# Clone Pilot
RUN git clone https://github.com/frappe/pilot.git

WORKDIR /opt/pilot

# Install dependencies using uv
RUN uv venv

# IMPORTANT: install project properly
RUN uv pip install .

# Expose Pilot port
EXPOSE 7000

# Run via installed CLI (NOT python module)
CMD ["pilot"]
