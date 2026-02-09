# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LLM Council: a 3-stage deliberation system where multiple LLMs (via OpenRouter) collaboratively answer user questions. Stage 1 collects individual responses, Stage 2 does anonymized peer ranking, Stage 3 has a chairman model synthesize a final answer.

## Development Commands

### Backend (Python, managed with uv)
```bash
uv sync                          # Install/update Python dependencies
uv run python -m backend.main    # Start backend on port 8001
```

### Frontend (React + Vite)
```bash
cd frontend && npm install       # Install JS dependencies
cd frontend && npm run dev       # Start dev server on port 5173
cd frontend && npm run build     # Production build
cd frontend && npm run preview   # Preview production build
cd frontend && npm run lint      # Run ESLint
```

### Quick Start (both together)
```bash
./start.sh                       # Runs backend + frontend preview (production mode)
```

### Docker
```bash
docker build -t llm-council .    # Build container (installs both Python + Node deps)
```

## Architecture

**Backend** (`backend/`) - FastAPI async Python app:
- `config.py` - `COUNCIL_MODELS` list, `CHAIRMAN_MODEL`, API key from `.env`
- `openrouter.py` - HTTP client for OpenRouter API; `query_model()` and `query_models_parallel()` with `asyncio.gather()`
- `council.py` - Core 3-stage orchestration: `stage1_collect_responses()`, `stage2_collect_rankings()`, `stage3_synthesize_final()`, plus ranking parsing and aggregation
- `storage.py` - JSON file storage in `data/conversations/`
- `main.py` - FastAPI routes, CORS config, both batch and SSE streaming endpoints

**Frontend** (`frontend/src/`) - React 19 + Vite 7:
- `api.js` - Backend client with SSE streaming support (`sendMessageStream`)
- `App.jsx` - Main state management, progressive SSE event handling
- `components/` - `Sidebar`, `ChatInterface`, `Stage1`, `Stage2`, `Stage3` (each with paired `.css`)

**Data flow**: User query → Stage 1 (parallel model queries) → Stage 2 (anonymized peer ranking) → aggregate rankings → Stage 3 (chairman synthesis) → response with metadata

## Key Implementation Details

- **Backend must be run as a module**: `python -m backend.main` from project root (relative imports throughout)
- **Port 8001**: Backend runs on 8001, not 8000. Update `backend/main.py` and `frontend/src/api.js` if changing
- **CORS origins**: `localhost:5173` and `localhost:3000` are allowed in `backend/main.py`
- **Metadata is ephemeral**: `label_to_model` and `aggregate_rankings` are returned in API responses but NOT persisted to JSON storage
- **Stage 2 anonymization**: Models see "Response A, B, C..." not model names. De-anonymization happens client-side for display only
- **Ranking parsing**: Expects "FINAL RANKING:" header with numbered list; falls back to regex extraction of "Response X" patterns
- **Graceful degradation**: Failed model queries return None and are skipped; the flow continues with successful responses
- **Markdown rendering**: All ReactMarkdown components must be wrapped in `<div className="markdown-content">` (global styles in `index.css`)
- **SSE streaming**: The `/message/stream` endpoint sends progressive stage updates; `App.jsx` mutates the last assistant message in-place as events arrive
- **Python 3.10**: Required minimum version (`.python-version` file)
- **Environment**: Requires `OPENROUTER_API_KEY` in `.env` at project root