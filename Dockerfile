FROM python:3.10-slim

# Node.js 20
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Python deps
RUN pip install uv && uv sync

# Frontend build
RUN cd frontend && npm install && npm run build

EXPOSE 8001

CMD ["uv", "run", "python", "-m", "backend.main"]
