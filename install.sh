#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plugin_src="${repo_root}/plugin"
skill_src="${repo_root}/skill/wiz-security"

plugin_dst="${HOME}/plugins/wiz-security"
skill_dst="${HOME}/.codex/skills/wiz-security"
marketplace_dir="${HOME}/.agents/plugins"
marketplace_file="${marketplace_dir}/marketplace.json"

if ! command -v rsync >/dev/null 2>&1; then
  echo "rsync is required but not installed." >&2
  exit 127
fi

mkdir -p "${HOME}/plugins" "${HOME}/.codex/skills" "${marketplace_dir}"

rsync -a "${plugin_src}/" "${plugin_dst}/"
rsync -a "${skill_src}/" "${skill_dst}/"

chmod +x \
  "${plugin_dst}/scripts/wiz_scan_fetch.sh" \
  "${skill_dst}/scripts/wiz_scan_fetch.sh"

python3 - "$marketplace_file" <<'PY'
import json
import pathlib
import sys

marketplace_path = pathlib.Path(sys.argv[1])

default = {
    "name": "local-plugins",
    "interface": {"displayName": "Local Plugins"},
    "plugins": [],
}

if marketplace_path.exists():
    data = json.loads(marketplace_path.read_text())
else:
    data = default

plugins = data.setdefault("plugins", [])
entry = {
    "name": "wiz-security",
    "source": {
        "source": "local",
        "path": "./plugins/wiz-security",
    },
    "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL",
    },
    "category": "Coding",
}

for idx, plugin in enumerate(plugins):
    if plugin.get("name") == "wiz-security":
        plugins[idx] = entry
        break
else:
    plugins.append(entry)

marketplace_path.write_text(json.dumps(data, indent=2) + "\n")
PY

cat <<EOF
Installed Wiz Codex bundle.

Plugin:
  ${plugin_dst}

Standalone skill:
  ${skill_dst}

Marketplace:
  ${marketplace_file}

Next steps:
1. Fully quit VS Code
2. Reopen VS Code
3. Start a brand new Codex session
4. Ask Codex: Use Wiz to scan this repo and walk me through the top risks
EOF
