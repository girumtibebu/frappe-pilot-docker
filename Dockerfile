FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*


# install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/root/.local/bin:$PATH"


# get pilot source
RUN git clone https://github.com/frappe/pilot.git .


# install dependencies using uv
RUN uv sync


EXPOSE 8000


CMD ["uv", "run", "pilot"]
