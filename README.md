# Condor Documentation

Documentation site for [Condor](https://github.com/hummingbot/condor), published at [condor.hummingbot.org](https://condor.hummingbot.org) and built with [Mintlify](https://mintlify.com). It also hosts the [Hummingbot API](https://github.com/hummingbot/hummingbot-api) reference, generated from that server's OpenAPI spec.

## Repository Structure

```
condor-docs/
├── docs.json              # Mintlify config: navigation, theme, redirects, OpenAPI source
├── style.css              # Site-wide CSS overrides
├── introduction.mdx       # Homepage
├── *.mdx                  # Other root pages: learning-path, motivation, feedback,
│                          #   llm-integration, api-reference (API overview)
│
├── getting-started/       # Install, configure, Telegram, web dashboard, first agent
├── examples/              # Shipped agents and step-by-step agent guides
├── webui/                 # One page per web dashboard page
├── bots/                  # Controllers, scripts, backtesting
├── executors/             # Executor types
├── routines/              # Routines and reports
├── trading-agents/        # Agent architecture, sessions, MCP tools
├── condor-agent/          # The Condor assistant and Agent Builder
├── api-reference/         # Hummingbot API pages: architecture, Gateway, Hummingbot
│   └── openapi.json       # Spec Mintlify renders (generated, see below)
├── videos/                # Overview, Agent Builders Cup workshops, The Bot Pod episodes
├── snippets/              # Reusable MDX snippets
│
├── openapi-sources/
│   └── hummingbot-api.json  # Raw spec fetched from a running Hummingbot API
├── scripts/
│   ├── generate-openapi.sh  # Fetch the spec from a running server and write api-reference/openapi.json
│   └── update-openapi.sh    # Rebuild api-reference/openapi.json from openapi-sources/hummingbot-api.json
│
├── images/                # Screenshots and diagrams (images/webui/ for dashboard captures)
└── logo/                  # Site logos and favicon
```

## Previewing these docs locally

**There is no preview link on pull requests.** Mintlify only builds those on its Pro and
Enterprise plans, so the local preview below is how you see your work before it merges —
and how a reviewer sees it. It needs no Mintlify account.

### Prerequisites

- Node.js 18+
- Nothing else — `npx` fetches the CLI on demand

### Preview

From the repository root, the directory containing `docs.json`:

```bash
npx mint@latest dev
```

View at http://localhost:3000. The page reloads as you edit, and `--port 3001` moves it if
something already holds 3000. The CLI also prints a LAN address, which reaches someone on
the same network but nobody else.

> If `npx mint@latest` fails to install (in October 2026 it failed because a dependency,
> `@mintlify/og`, pointed at an unpublished version), run a copy already in your npx cache
> instead: `ls ~/.npm/_npx/*/node_modules/.bin/mint`, then call that path with the same
> arguments (`dev`, `validate`, `broken-links`).

> The CLI was renamed: it is `mint`, not `mintlify`. Older instructions saying
> `npm i -g mintlify` still work by installing a deprecated package. `npx mint@latest`
> always fetches the current version, so there is nothing to install or keep updated.

### Check it before you push

```bash
npx mint@latest validate       # docs.json, navigation paths, frontmatter
npx mint@latest broken-links --check-anchors   # every internal link and #anchor
```

Both are quick, and between them they catch the two things that actually break a docs
build: a page missing from `docs.json`, and a link to a heading that was renamed.

### Reviewing someone else's branch

```bash
git fetch origin && git checkout <branch>
npx mint@latest dev
```

> Search is inactive locally until you run `mint login` — the CLI says so on startup.
> Everything else renders exactly as it will in production.

## Updating the OpenAPI Spec

The API Reference is generated from the Hummingbot API's OpenAPI spec. There are two ways to update it.

### Method 1: Fetch from a running server (recommended)

```bash
# Start the Hummingbot API first (localhost:8000)
cd ~/hummingbot-api
make setup    # first time only: writes .env with your credentials
make deploy   # starts the API, PostgreSQL and EMQX in Docker
              # (or `make run` to run the API from source; it also needs .env)

# Then, from this repo:
./scripts/generate-openapi.sh
```

The script fetches `http://localhost:8000/openapi.json` (set `HBAPI_URL` to use another
server; no credentials are needed), saves the raw copy to
`openapi-sources/hummingbot-api.json`, and writes the spec Mintlify renders to
`api-reference/openapi.json` with the `servers` entry the API playground uses.

### Method 2: From a file you already have

1. Save the spec to `openapi-sources/hummingbot-api.json`.
2. Run:
   ```bash
   ./scripts/update-openapi.sh
   ```

This validates the JSON, adds the same `servers` entry, and writes `api-reference/openapi.json`.

### After updating

1. Run `npx mint@latest dev` and check the API Reference sidebar and endpoint pages.
2. Commit both `openapi-sources/hummingbot-api.json` and `api-reference/openapi.json`.

## Troubleshooting

### 404 on pages
Run the CLI from the directory containing `docs.json`, and check that the page is listed in
the `navigation` section of `docs.json`.

## Publishing

Changes pushed to the main branch are automatically deployed via Mintlify's GitHub integration.

## Resources

- [Mintlify Documentation](https://mintlify.com/docs)
- [Hummingbot API Repository](https://github.com/hummingbot/hummingbot-api)
- [Condor Repository](https://github.com/hummingbot/condor)
