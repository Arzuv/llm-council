FROM python:3.10-slim

RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN pip install uv && uv sync
RUN cd frontend && npm install && npm run build

# Делаем start.sh исполняемым
RUN chmod +x start.sh

# Запускаем start.sh
CMD ["./start.sh"]
