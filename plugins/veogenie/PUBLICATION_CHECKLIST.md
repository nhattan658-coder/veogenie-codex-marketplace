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

Verify the public metadata in:

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

The current public target is:

```text
https://github.com/nhattan658-coder/veogenie-codex-marketplace
```

The policy/license files must be present before export:

```text
PRIVACY.md
TERMS.md
LICENSE.md
```

Agent instruction files must also be present before export:

```text
AGENTS.md
CLAUDE.md
```

`npm run plugin:export` rejects plugin metadata if any public plugin metadata file still contains local-test URLs.

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
It also includes root-level `AGENTS.md` and `CLAUDE.md` so Codex and Claude can read the exact MCP run/export workflow before using the plugin.

If publishing via GitHub, push the standalone marketplace root so Codex can add the repo with:

```text
Source: https://github.com/<owner>/veogenie-codex-marketplace.git
Git ref: main
Sparse paths: leave empty
```

After adding the marketplace, verify the plugin is enabled. If the UI does not expose an install button, document the fallback:

```toml
[plugins."veogenie@veogenie-marketplace"]
enabled = true
```

## Default Safety

- Keep `.mcp.json` read-only by default.
- Do not enable `VEOGENIE_MCP_ALLOW_ACTIONS`, `VEOGENIE_MCP_ALLOW_CANVAS_WRITE`, `VEOGENIE_MCP_ALLOW_MEDIA_EXPORT`, `VEOGENIE_MCP_ALLOW_MEDIA_IMPORT`, `VEOGENIE_MCP_ALLOW_PROJECT_EXPORT`, or `VEOGENIE_MCP_ALLOW_RUN` by default.
- `grant_mcp_session_permissions` may be available, but it must only grant temporary permissions after the user explicitly approves the action in chat.
- Keep `run_workflow_payload` env-only via `VEOGENIE_MCP_ALLOW_RUN=1`; do not allow session grants for raw workflow payloads.
- Document guarded tools as opt-in only.
- Document result handoff: Codex must read `get_node_outputs` and node-specific `get_media_album`, then export verified `mediaId` values if files are needed. It must not show a separate chat-generated image as the VeoGenie result.
- Do not include source app code, license issuer/private key, admin routes, media payloads, or customer data in the public plugin repository.

## Smoke Test

With the app open, ask Codex:

```text
Use the VeoGenie MCP plugin to call get_mcp_capabilities, get_app_status, list_pages, and get_current_workflow.
Optionally call build_product_ad_workflow_recipe with a sample product brief and confirm it only returns a recipe.
Optionally call get_run_orchestration_status with a known nodeId only after confirming it is read-only and does not queue a run.
Do not run Google Flow, ChatGPT, GPT Image 2, create/append pages, import media, export files, run_node, run_group, or run_workflow_payload.
```
