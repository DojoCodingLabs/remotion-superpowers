#!/bin/bash
# Remotion Superpowers — Pre-tool MCP server check hook
# Called by Claude Code before MCP tool execution.
#
# Usage: sh scripts/check-mcp-server.sh <server-name> <env-var-name>
# Receives hook JSON on stdin. Outputs JSON decision on stdout.
#
# Exit codes:
#   0 = success (approve tool call)
#   2 = blocking error (prevent tool call, show reason)

SERVER_NAME="${1:-unknown}"
ENV_VAR="${2:-UNKNOWN_KEY}"

# Read stdin (hook JSON) — we don't need it for this check but consume it
cat > /dev/null 2>&1

# Check if the required environment variable is set
ENV_VALUE=$(printenv "$ENV_VAR" 2>/dev/null)

if [ -n "$ENV_VALUE" ]; then
  # Env var is set — approve the tool call
  exit 0
else
  # Env var is missing — block with helpful message
  echo "{\"decision\": \"block\", \"reason\": \"$ENV_VAR is not set. The $SERVER_NAME MCP server needs this key. Run /setup to configure your API keys.\"}"
  exit 2
fi
