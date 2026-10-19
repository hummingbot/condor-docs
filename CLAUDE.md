# Condor & Hummingbot API Documentation

## Working relationship
- You can push back on ideas - this can lead to better documentation. Cite sources and explain your reasoning when you do so
- ALWAYS ask for clarification rather than making assumptions
- NEVER lie, guess, or make up information

## Project context

This documentation covers **Condor** (web dashboard, Telegram bot and LLM trading agents) and the **Hummingbot API** (the backend server Condor drives). It is a focused subset of the main Hummingbot documentation, not a complete replacement.

### Source repositories
- **Condor**: https://github.com/hummingbot/condor
- **Hummingbot API**: https://github.com/hummingbot/hummingbot-api
- **API Client**: https://github.com/hummingbot/hummingbot-api-client

### Reference documentation
- Main Hummingbot docs: `~/hummingbot-site`
- Relevant sections: `docs/condor/`, `docs/hummingbot-api/`, `docs/mcp/`, `docs/gateway/`

### Tech stack
- Format: MDX files with YAML frontmatter
- Config: `docs.json` for navigation, theme, settings
- Framework: Mintlify
- Components: Mintlify components (Cards, Tabs, Accordions, etc.)

## Architecture overview

```
Browser (web dashboard)      Telegram user
            \                  /
     Condor (web dashboard + Telegram bot + LLM trading agents)
            |         \
            |          +---> LLM providers (agent and assistant models)
            |
     Hummingbot API (FastAPI server)
            |
            +---> PostgreSQL (trading data)
            +---> EMQX (message broker for bots)
            +---> Exchange connectors (CEX trading)
            +---> Gateway (DEX trading; started and managed by the API)
```

Condor never talks to Gateway directly: every DEX action goes through the Hummingbot API.

### Key concepts
- **Condor**: Web dashboard, Telegram bot and LLM trading agents on top of Hummingbot infrastructure
- **Hummingbot API**: RESTful API for managing trading operations, bot orchestration, and exchange connectivity
- **Gateway**: Separate service for DEX trading (swaps, liquidity pools), reached through the Hummingbot API
- **Controllers**: Trading strategy components running inside bot instances

## Repository structure

```
├── docs.json            # Mintlify config (navigation, theme, redirects, OpenAPI)
├── introduction.mdx     # Homepage (other root pages: learning-path, motivation,
│                        #   feedback, llm-integration, api-reference)
├── getting-started/     # Install, configure, Telegram, web dashboard, first agent
├── examples/            # Shipped agents and step-by-step agent guides
├── webui/               # Web dashboard pages
├── bots/                # Controllers, scripts, backtesting
├── executors/           # Executor types
├── routines/            # Routines and reports
├── trading-agents/      # Agent architecture, sessions, MCP tools
├── condor-agent/        # The Condor assistant and Agent Builder
├── api-reference/       # Hummingbot API pages + openapi.json (generated)
├── videos/              # Videos overview, Agent Builders Cup, The Bot Pod
├── snippets/            # Reusable MDX snippets
├── images/              # Screenshots and diagrams (images/webui/ for dashboard)
├── logo/                # Logos and favicon
├── openapi-sources/     # Raw spec fetched from the Hummingbot API
└── scripts/             # OpenAPI generate/update scripts
```

## OpenAPI spec maintenance

The API Reference is auto-generated from the OpenAPI spec. When endpoints change in the source repo, regenerate the spec:

### Quick update (server already running)

```bash
./scripts/generate-openapi.sh
```

### Full update workflow

1. Start the Hummingbot API server:
   ```bash
   cd ~/hummingbot-api
   make setup    # first time only: writes .env with your credentials
   make deploy   # API on localhost:8000 (`make run` runs it from source; also needs .env)
   ```

2. Generate spec:
   ```bash
   ./scripts/generate-openapi.sh
   ```

3. Preview and verify:
   ```bash
   npx mint@latest dev
   ```

4. Commit both `openapi-sources/hummingbot-api.json` and `api-reference/openapi.json`

### Fixing issues

If changes to router docstrings aren't appearing, restart the source server and re-fetch the spec.

## Content strategy
- Document just enough for user success - not too much, not too little
- Prioritize accuracy and usability of information
- Make content evergreen when possible
- Search `~/hummingbot-site` for existing information before adding new content
- Check existing patterns in this repo for consistency
- Start by making the smallest reasonable changes

## Frontmatter requirements

Every MDX file must include:

```yaml
---
title: "Clear, descriptive page title"
description: "Concise summary for SEO/navigation (1-2 sentences)"
---
```

## Writing standards
- Second-person voice ("you")
- Prerequisites at start of procedural content
- Test all code examples before publishing
- Match style and formatting of existing pages
- Include both basic and advanced use cases where relevant
- Language tags on all code blocks (```bash, ```python, ```yaml, etc.)
- Alt text on all images
- Relative paths for internal links

## Git workflow
- NEVER use `--no-verify` when committing
- Ask how to handle uncommitted changes before starting
- Create a new branch when no clear branch exists for changes
- Commit frequently throughout development
- NEVER skip or disable pre-commit hooks

## Do not
- Skip frontmatter on any MDX file
- Use absolute URLs for internal links
- Include untested code examples
- Make assumptions - always ask for clarification
- Duplicate content from `~/hummingbot-site` unless strategically necessary
- Add fallback values or mock data - throw clear errors instead

## Mintlify dev server
```bash
# Start local preview (available at http://localhost:3000)
npx mint@latest dev

# Before committing: check config/frontmatter, then links and anchors
npx mint@latest validate
npx mint@latest broken-links --check-anchors
```

If `npx mint@latest` fails to install, run a copy already in the npx cache
(`ls ~/.npm/_npx/*/node_modules/.bin/mint`) with the same arguments.

## Common documentation patterns

### Installation guides
1. Prerequisites section first
2. Docker method (recommended) before source method
3. Environment configuration
4. Verification steps

### Command/feature documentation
1. Brief description
2. Supported options/exchanges
3. Step-by-step usage
4. Code examples
5. Common issues/troubleshooting (if needed)

### API endpoint documentation
- Use Mintlify's OpenAPI integration where possible
- Include request/response examples
- Document authentication requirements
