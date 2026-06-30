FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:$PATH"

RUN apt update && apt install -y \
    curl \
    git \
    sudo \
    ca-certificates \
    openssh-server \
    python3 \
    python3-venv \
    docker.io \
    docker-compose-plugin \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*


# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh


WORKDIR /opt


# Get Pilot
RUN git clone https://github.com/frappe/pilot.git


WORKDIR /opt/pilot


# Create environment and install dependencies
RUN uv venv

RUN uv sync


EXPOSE 7000


CMD ["/opt/pilot/.venv/bin/python", "main.py"]
