# VeoGenie Codex Plugin Publication Checklist

Use this checklist before copying this plugin into a public repository.

## App Release

- Build and publish a VeoGenie Tool installer that includes:
  - `D:\VeoGenie Tool\veogenie-mcp.cmd`
  - `D:\VeoGenie Tool\runtime\mcp-server\index.mjs`
  - `D:\VeoGenie Tool\runtime\node\node.exe`
- Install the release build on a clean Windows machine or VM.
- Open the desktop app and verify:

```powershell
Invoke-RestMethod http://127.0.0.1:8788/health
```

## Plugin Metadata

Replace the local-test metadata in:

```text
.codex-plugin/plugin.json
```

Required values:

- publisher name
- contact email
- publisher URL
- documentation/homepage URL
- public plugin repository URL
- license
- website URL
- privacy policy URL
- terms of service URL

Do not publish the default `example.com` URLs.

## Plugin Export

From the app repo root, run:

```powershell
npm run plugin:export
```

The export output is:

```text
dist/codex-plugin/veogenie
```

Use that folder when copying the plugin into an existing marketplace repo at `plugins/veogenie`.

For a standalone repo/folder that Codex can add directly as a marketplace, use:

```text
dist/codex-marketplace
```

This folder contains `.agents/plugins/marketplace.json` plus `plugins/veogenie`, and does not contain the desktop app source.

## Default Safety

- Keep `.mcp.json` read-only by default.
- Do not enable `VEOGENIE_MCP_ALLOW_ACTIONS`, `VEOGENIE_MCP_ALLOW_CANVAS_WRITE`, `VEOGENIE_MCP_ALLOW_MEDIA_EXPORT`, or `VEOGENIE_MCP_ALLOW_RUN` by default.
- Document guarded tools as opt-in only.
- Do not include source app code, license issuer/private key, admin routes, media payloads, or customer data in the public plugin repository.

## Smoke Test

With the app open, ask Codex:

```text
Use the VeoGenie MCP plugin to call get_mcp_capabilities, get_app_status, list_pages, and get_current_workflow.
Do not run Google Flow, ChatGPT, GPT Image 2, run_node, run_group, or run_workflow_payload.
```
