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

## Step 2 — Locate the Codex plugin MCP config

The Codex plugin installs its MCP configuration at:

`~/plugins/wiz-security/.mcp.json`

Codex plugins use a plugin-local `.mcp.json`, not `~/.claude.json` and not `claude mcp add`.

## Step 3 — Update the MCP URL

Edit `~/plugins/wiz-security/.mcp.json` so the `wiz-mcp` server points at the desired URL:

```json
{
  "mcpServers": {
    "wiz-mcp": {
      "type": "http",
      "url": "<URL>"
    }
  }
}
```

Default environment:

`https://mcp.app.wiz.io`

Common alternates:

- `https://mcp.demo.wiz.io`
- `https://mcp.test.wiz.io`
- `https://mcp.<env>.wiz.io`

## Step 4 — Authentication mode

### OAuth path

For standard browser-based OAuth, the default plugin-local entry is enough:

```json
{
  "mcpServers": {
    "wiz-mcp": {
      "type": "http",
      "url": "<URL>"
    }
  }
}
```

When Codex first tries to use the server, it should prompt for authorization if your Wiz tenant supports OAuth.

### Service account path

Only use this if the user explicitly asks for service-account auth and already has:

- `WIZ_CLIENT_ID`
- `WIZ_CLIENT_SECRET`
- `WIZ_DATACENTER`

Then update `~/plugins/wiz-security/.mcp.json` like this:

```json
{
  "mcpServers": {
    "wiz-mcp": {
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

Never print or log the `WIZ_CLIENT_SECRET` value.

## Step 5 — Restart Codex

After changing the plugin-local `.mcp.json`, restart Codex so it reloads the plugin and MCP configuration.

## Step 6 — Confirm and remind

Confirm the configured URL and auth mode, then remind the user:

1. Ensure Remote MCP Server is enabled in Wiz:
   `Settings > Tenant > AI Features`
2. Restart Codex if `.mcp.json` changed
3. Test with:
   `/wiz-remediate this repo`
