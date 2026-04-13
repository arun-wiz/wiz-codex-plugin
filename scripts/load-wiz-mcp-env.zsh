#!/bin/zsh
set -euo pipefail

typeset wiz_client_id=""
typeset wiz_client_secret=""
typeset wiz_datacenter=""

read -r "?Wiz Client ID: " wiz_client_id
if [[ -z "$wiz_client_id" ]]; then
  print -u2 -- "WIZ_CLIENT_ID is required."
  exit 1
fi

read -rs "?Wiz Client Secret: " wiz_client_secret
print
if [[ -z "$wiz_client_secret" ]]; then
  print -u2 -- "WIZ_CLIENT_SECRET is required."
  exit 1
fi

read -r "?Wiz Datacenter [us36]: " wiz_datacenter
if [[ -z "$wiz_datacenter" ]]; then
  wiz_datacenter="us36"
fi

launchctl setenv WIZ_CLIENT_ID "$wiz_client_id"
launchctl setenv WIZ_CLIENT_SECRET "$wiz_client_secret"
launchctl setenv WIZ_DATACENTER "$wiz_datacenter"

echo "Wiz MCP environment loaded into launchd for this login session."
echo "Fully restart VS Code/Codex to pick it up."
