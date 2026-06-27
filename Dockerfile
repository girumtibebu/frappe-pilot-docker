FROM ubuntu:24.04

# Avoid prompt freezes during apt installations
ENV DEBIAN_FRONTEND=noninteractive

# Install framework dependencies, build tools, and utilities
RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    wget \
    python3 \
    python3-pip \
    python3-venv \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Create dedicated frappe runtime user with passwordless privileges
RUN useradd -m -s /bin/bash frappe && \
    echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/frappe && \
    chmod 0440 /etc/sudoers.d/frappe

# Create a fake systemctl tool to trick the Pilot installer script
RUN echo '#!/bin/sh\nexit 0' > /usr/local/bin/systemctl && \
    chmod +x /usr/local/bin/systemctl

USER frappe
WORKDIR /home/frappe

# Download and execute the official pilot installer script
RUN curl -fsSL https://raw.githubusercontent.com/frappe/pilot/main/install.sh | bash -s -- --user frappe -y

# Future-proofed path bindings reflecting the official pilot rename
ENV PATH="/home/frappe/pilot:/home/frappe/.local/bin:${PATH}"

# Force backend workers and Flask to bind to IPv4 instead of local IPv6 loopback
ENV HOST=0.0.0.0
ENV FLASK_RUN_HOST=0.0.0.0

EXPOSE 8002 7000

# Automated boot intercept: seeds workspace layout on empty volume, then spins up the daemon
CMD ["sh", "-c", "if [ ! -f bench.toml ] && [ ! -d benches ]; then bench new emc; fi; exec bench start"]
