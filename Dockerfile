FROM python:3.14-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*


RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/root/.local/bin:$PATH"


RUN git clone https://github.com/frappe/pilot.git .


RUN uv sync


EXPOSE 8000


CMD ["uv", "run", "python", "-m", "pilot"]
