FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:$PATH"

RUN apt update && apt install -y \
    curl \
    wget \
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


# install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh


RUN useradd -ms /bin/bash frappe \
    && usermod -aG docker frappe


WORKDIR /opt


RUN git clone https://github.com/frappe/pilot.git


WORKDIR /opt/pilot


# create python environment + install deps
RUN uv venv


RUN uv pip install -r requirements.txt


COPY start.sh /start.sh

RUN chmod +x /start.sh


EXPOSE 8000


CMD ["/start.sh"]
