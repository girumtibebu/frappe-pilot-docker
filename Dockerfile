FROM ubuntu:24.04

# Enable systemd initialization context inside Docker
ENV DEBIAN_FRONTEND=noninteractive
ENV container=docker

# Install full systemd suite alongside core platform utilities
RUN apt-get update && apt-get install -y \
    systemd \
    systemd-sysv \
    curl \
    git \
    sudo \
    wget \
    python3 \
    python3-pip \
    python3-venv \
    lsof \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Clean up unnecessary systemd target triggers to prevent boot delays
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i = systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# Create dedicated frappe runtime user with passwordless privileges
RUN useradd -m -s /bin/bash frappe && \
    echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/frappe && \
    chmod 0440 /etc/sudoers.d/frappe

USER frappe
WORKDIR /home/frappe

# Download and execute the official pilot installer script
RUN curl -fsSL https://raw.githubusercontent.com/frappe/pilot/main/install.sh | bash -s -- --user frappe -y

# Configure persistent system path binds
ENV PATH="/home/frappe/pilot:/home/frappe/.local/bin:${PATH}"
ENV HOST=0.0.0.0
ENV FLASK_RUN_HOST=0.0.0.0

EXPOSE 8002 7000

USER root

# Write a startup hook that lets systemd boot up as PID 1, then automatically triggers the bench daemon in the background
RUN echo '#!/bin/sh\n\
(while [ ! -f /var/run/systemd/seats/ ]; do sleep 1; done; \
 sudo -H -u frappe sh -c "if [ ! -f /home/frappe/bench.toml ] && [ ! -d /home/frappe/benches ]; then /home/frappe/.local/bin/bench new emc; fi; /home/frappe/.local/bin/bench start") &\n\
exec /lib/systemd/systemd' > /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh

STOPSIGNAL SIGRTMIN+3

CMD ["/usr/local/bin/entrypoint.sh"]
