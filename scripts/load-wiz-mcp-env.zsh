#!/bin/zsh
set -euo pipefail

launchctl setenv WIZ_CLIENT_ID "$(security find-generic-password -a "$USER" -s codex-wiz-client-id -w)"
launchctl setenv WIZ_CLIENT_SECRET "$(security find-generic-password -a "$USER" -s codex-wiz-client-secret -w)"
launchctl setenv WIZ_DATACENTER "${WIZ_DATACENTER:-us36}"

echo "Wiz MCP environment loaded into launchd for this login session."
echo "Fully restart VS Code/Codex to pick it up."
