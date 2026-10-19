#!/bin/bash
# Rebuild the API Reference spec from a saved copy
#
# Usage: ./scripts/update-openapi.sh
#
# Use this when you already have openapi-sources/hummingbot-api.json (for
# example, saved from another server's /openapi.json). To fetch a fresh copy
# from a running server instead, use ./scripts/generate-openapi.sh.
#
# This script:
# 1. Validates openapi-sources/hummingbot-api.json
# 2. Adds the `servers` entry Mintlify's playground uses as its base URL and
#    saves the result to api-reference/openapi.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="$ROOT_DIR/openapi-sources"
RAW_SPEC="$SOURCE_DIR/hummingbot-api.json"
DOCS_SPEC="$ROOT_DIR/api-reference/openapi.json"

# The playground base URL written into the published spec. Keep in sync with
# scripts/generate-openapi.sh.
SERVERS_JQ='. + {servers: [{url: "http://localhost:8000", description: "Local development server"}]}'

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: 'jq' is required but not installed." >&2
    exit 1
fi

if [ ! -f "$RAW_SPEC" ]; then
    echo "Error: openapi-sources/hummingbot-api.json not found." >&2
    echo "Save a server's /openapi.json there, or run ./scripts/generate-openapi.sh." >&2
    exit 1
fi

if ! jq -e '.openapi and .paths' "$RAW_SPEC" >/dev/null 2>&1; then
    echo "Error: openapi-sources/hummingbot-api.json is not an OpenAPI document" >&2
    exit 1
fi

echo "Updating OpenAPI spec..."
jq "$SERVERS_JQ" "$RAW_SPEC" > "$DOCS_SPEC"

VERSION=$(jq -r '.info.version // "unknown"' "$RAW_SPEC")
PATHS=$(jq '.paths | keys | length' "$RAW_SPEC")
echo "  Version: $VERSION"
echo "  Paths: $PATHS"
echo "  Saved to: api-reference/openapi.json"
echo ""
echo "Done. Run 'npx mint@latest dev' to preview the changes."
