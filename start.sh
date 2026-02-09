#!/bin/bash

# LLM Council - Start script

echo "Starting LLM Council..."
echo ""

# Start backend
echo "Starting backend on http://localhost:8001..."
uv run python -m backend.main &
BACKEND_PID=$!

# Wait a bit for backend to start
sleep 2

# Start frontend
echo "Starting frontend on http://localhost:5173..."
echo "Building frontend..."
cd frontend
npm install
npm run build
cd ..

echo ""
echo "✓ LLM Council is running!"
echo "  Backend:  http://localhost:8001"
echo "  Frontend: http://localhost:5173"
echo ""

echo "Starting backend on http://0.0.0.0:8001..."
uv run python -m backend.main
