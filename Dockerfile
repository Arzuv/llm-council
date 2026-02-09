FROM python:3.10-slim

RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies (cached layer)
COPY pyproject.toml uv.lock ./
RUN pip install uv && uv sync

# Install and build frontend (cached layer)
COPY frontend/package.json frontend/package-lock.json frontend/
RUN cd frontend && npm ci

# Copy the rest of the source code
COPY . .

# Build frontend
RUN cd frontend && npm run build

# Single process: FastAPI serves API + static frontend
CMD ["uv", "run", "python", "-m", "backend.main"]
