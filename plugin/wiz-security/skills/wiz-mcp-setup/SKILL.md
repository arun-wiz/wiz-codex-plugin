---
name: wiz-mcp-setup
description: Configure the remote Wiz MCP server in Codex. Supports all Wiz environments (app, demo, test, custom URLs). Default auth is browser-based OAuth; service account headers can be added only if explicitly requested with credentials. Use when the user wants to set up or reconfigure the Wiz MCP server.
disable-model-invocation: true
---

# Wiz MCP Setup

Configure the remote Wiz MCP server for use with Codex.

> **Prerequisite:** Remote MCP Server must be enabled on the
> **Settings > Tenant > AI Features** page in your Wiz portal before proceeding.

## Step 1 — Determine the Wiz MCP URL

- If an argument was passed (`$ARGUMENTS`):
  - If it contains a `.`: treat it as the full URL. Add `https://` if no scheme is present.
    - Example: `mcp.test.wiz.io` -> `https://mcp.test.wiz.io`
  - If it contains no `.`: treat it as an environment shorthand and construct `https://mcp.<arg>.wiz.io`
    - Example: `test` -> `https://mcp.test.wiz.io`
- Otherwise use the default: `https://mcp.app.wiz.io`

## Step 2 — Derive the MCP entry name from the URL

Use the URL to derive the entry name inside `.mcp.json`:

- `https://mcp.app.wiz.io` -> `wiz-mcp`
- `https://mcp.<env>.wiz.io` -> `wiz-mcp-<env>`
  - Example: `https://mcp.test.wiz.io` -> `wiz-mcp-test`
- Any other URL -> `wiz-mcp-custom`

When reconfiguring an existing entry in place, keep the existing key instead of renaming it unless the user explicitly asks to clean it up.

## Step 3 — Locate the Codex plugin MCP config

The Codex plugin installs its MCP configuration at:

`~/plugins/wiz-security/.mcp.json`

Codex plugins use a plugin-local `.mcp.json`, not `~/.claude.json` and not `claude mcp add`.

If `~/plugins/wiz-security/.mcp.json` does not exist, the plugin is probably not installed yet.
In that case, tell the user to install the repo first with `./install.sh` and then continue.

## Step 4 — Check for existing Wiz MCP configuration

Read `~/plugins/wiz-security/.mcp.json` and inspect the `mcpServers` object for:

1. URL match: any entry whose `url` exactly matches the target URL
2. Name match: any entry whose key matches the derived name
3. Wiz match: any entry whose key starts with `wiz-mcp`

If a match is found, show the user what exists:

```text
Found existing Wiz MCP configuration:
  Name: <entry name>
  URL:  <entry url>
  Auth: <OAuth | Service Account>
```

Then ask how they want to proceed:

- Keep existing: make no changes, confirm the current config, and stop
- Reconfigure: overwrite the matched entry in place with the new settings
- Create new alongside: add a new entry without touching the existing one

If multiple Wiz entries already exist, prefer an exact URL match first, then an exact name match, then the default `wiz-mcp` entry.

When creating a new entry alongside an existing one:

- Use the derived name from Step 2
- If that key already exists, append a numeric suffix such as `wiz-mcp-test-2`
- Never overwrite unrelated non-Wiz MCP servers in the same file

## Step 5 — Choose authentication method

Default to browser-based OAuth without asking unless the user explicitly requested service-account auth.

Only offer service-account auth if the user clearly asked for it or provided service-account credentials.

## Step 6a — OAuth path

For standard browser-based OAuth, write or update the selected entry in `~/plugins/wiz-security/.mcp.json`:

```json
{
  "mcpServers": {
    "<ENTRY_NAME>": {
      "type": "http",
      "url": "<URL>"
    }
  }
}
```

Rules:

- Merge only the selected entry into `mcpServers`
- Preserve unrelated MCP servers and unrelated Wiz entries
- If reconfiguring an existing service-account entry back to OAuth, remove the `headers` block from that entry
- Do not rewrite the whole file if only one entry needs to change

Default environment:

`https://mcp.app.wiz.io`

Common alternates:

- `https://mcp.demo.wiz.io`
- `https://mcp.test.wiz.io`
- `https://mcp.<env>.wiz.io`

When Codex first tries to use the server, it should prompt for authorization if the Wiz tenant supports OAuth.

## Step 6b — Service account path

Only use this if the user explicitly asked for service-account auth.

Look for credentials in this order:

1. `.env` in the current working directory
2. If missing there, ask the user for:
   - `WIZ_CLIENT_ID`
   - `WIZ_CLIENT_SECRET`
   - `WIZ_DATACENTER`

Never print or log the `WIZ_CLIENT_SECRET` value.

Once all three values are available, merge this into the selected entry:

```json
{
  "mcpServers": {
    "<ENTRY_NAME>": {
      "type": "http",
      "url": "<URL>",
      "headers": {
        "Wiz-Client-Id": "<WIZ_CLIENT_ID>",
        "Wiz-Client-Secret": "<WIZ_CLIENT_SECRET>",
        "Wiz-DataCenter": "<WIZ_DATACENTER>"
      }
    }
  }
}
```

If the entry already exists, update it in place rather than creating duplicate header blocks.

## Step 7 — Restart Codex

After changing the plugin-local `.mcp.json`, restart Codex so it reloads the plugin and MCP configuration.

## Step 8 — Confirm and remind

Confirm the final entry name, URL, and auth mode, then remind the user:

1. Ensure Remote MCP Server is enabled in Wiz:
   `Settings > Tenant > AI Features`
2. Restart Codex if `.mcp.json` changed
3. Test with:
   `/wiz-remediate this repo`
