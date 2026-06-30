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
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*


# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh


WORKDIR /opt


RUN git clone https://github.com/frappe/pilot.git


WORKDIR /opt/pilot


RUN uv venv


RUN uv sync


EXPOSE 7000


CMD ["/opt/pilot/.venv/bin/python", "main.py"]
