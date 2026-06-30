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
    python3-pip \
    docker.io \
    nodejs \
    npm \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/*


# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh


# SSH
RUN mkdir /var/run/sshd


# Root SSH password
RUN echo "root:changeme" | chpasswd


EXPOSE 22
EXPOSE 7000


CMD ["/usr/sbin/sshd", "-D"]
