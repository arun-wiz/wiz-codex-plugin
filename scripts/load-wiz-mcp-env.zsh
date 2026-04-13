#!/bin/zsh
set -euo pipefail

get_secret() {
  local env_name="$1"
  local keychain_name="$2"
  local value="${(P)env_name:-}"

  if [[ -n "$value" ]]; then
    print -r -- "$value"
    return 0
  fi

  security find-generic-password -a "$USER" -s "$keychain_name" -w
}

launchctl setenv WIZ_CLIENT_ID "$(get_secret WIZ_CLIENT_ID codex-wiz-client-id)"
launchctl setenv WIZ_CLIENT_SECRET "$(get_secret WIZ_CLIENT_SECRET codex-wiz-client-secret)"
launchctl setenv WIZ_DATACENTER "${WIZ_DATACENTER:-us36}"

echo "Wiz MCP environment loaded into launchd for this login session."
echo "Fully restart VS Code/Codex to pick it up."
