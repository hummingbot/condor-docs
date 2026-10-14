#!/bin/bash
# Generate the API Reference spec from a running Hummingbot API server
#
# Usage: ./scripts/generate-openapi.sh
#        HBAPI_URL=http://192.168.1.10:8000 ./scripts/generate-openapi.sh
#
# Prerequisite: a running Hummingbot API. From your hummingbot-api checkout:
#   make setup     # first time only: writes .env with your credentials
#   make deploy    # starts the API, PostgreSQL and EMQX in Docker
#
# This script:
# 1. Fetches the OpenAPI spec from $HBAPI_URL/openapi.json (no credentials
#    needed: the API serves /openapi.json without authentication)
# 2. Saves the raw copy to openapi-sources/hummingbot-api.json
# 3. Adds the `servers` entry Mintlify's playground uses as its base URL and
#    saves the result to api-reference/openapi.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="$ROOT_DIR/openapi-sources"
RAW_SPEC="$SOURCE_DIR/hummingbot-api.json"
DOCS_SPEC="$ROOT_DIR/api-reference/openapi.json"

# Server to fetch from. Override with HBAPI_URL.
API_URL="${HBAPI_URL:-http://localhost:8000}"

# The playground base URL written into the published spec. Keep in sync with
# scripts/update-openapi.sh.
SERVERS_JQ='. + {servers: [{url: "http://localhost:8000", description: "Local development server"}]}'

for cmd in curl jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: '$cmd' is required but not installed." >&2
        exit 1
    fi
done

mkdir -p "$SOURCE_DIR"

echo "=== Generating Hummingbot API OpenAPI spec ==="
echo "Fetching $API_URL/openapi.json..."

TMP_SPEC="$(mktemp)"
trap 'rm -f "$TMP_SPEC"' EXIT

if ! curl -sSf --connect-timeout 5 --max-time 60 "$API_URL/openapi.json" -o "$TMP_SPEC"; then
    echo "Error: could not fetch $API_URL/openapi.json" >&2
    echo "Start the Hummingbot API first. From your hummingbot-api checkout:" >&2
    echo "  make setup    # first time only" >&2
    echo "  make deploy" >&2
    echo "Or point this script at another server: HBAPI_URL=http://host:8000 $0" >&2
    exit 1
fi

if ! jq -e '.openapi and .paths' "$TMP_SPEC" >/dev/null 2>&1; then
    echo "Error: $API_URL/openapi.json did not return an OpenAPI document" >&2
    exit 1
fi

jq . "$TMP_SPEC" > "$RAW_SPEC"
jq "$SERVERS_JQ" "$RAW_SPEC" > "$DOCS_SPEC"

VERSION=$(jq -r '.info.version // "unknown"' "$RAW_SPEC")
PATHS=$(jq '.paths | keys | length' "$RAW_SPEC")
echo "  Version: $VERSION"
echo "  Paths: $PATHS"
echo "  Raw copy: openapi-sources/hummingbot-api.json"
echo "  Docs spec: api-reference/openapi.json"
echo ""
echo "Done. Run 'npx mint@latest dev' to preview the changes."
