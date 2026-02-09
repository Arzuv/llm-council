#!/bin/bash

echo "Starting LLM Council..."

# Запускаем backend
echo "Starting backend..."
uv run python -m backend.main &

# Запускаем frontend (preview mode для production)
echo "Starting frontend..."
cd frontend
npm run preview -- --host 0.0.0.0 --port ${PORT:-5173}
