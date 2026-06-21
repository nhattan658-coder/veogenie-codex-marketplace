# VeoGenie Hermes Agent Offline Package

This folder lets Hermes Agent use the local VeoGenie desktop app through MCP and gives Hermes the same workflow skills used by the Codex plugin.

## What Is Included

```text
README-HERMES.md
HERMES_INSTRUCTIONS.md
mcp-config.json
mcp-config.absolute.example.json
bin/veogenie-mcp-launcher.cmd
skills/
```

`mcp-config.json` starts the VeoGenie MCP server through the bundled launcher resolver. `skills/` contains the workflow guides that Hermes should read before designing, running, or reporting VeoGenie jobs.

## Customer Install Steps

1. Install VeoGenie Tool Agent. Open it manually once, or let Hermes call `open_installed_app` after you ask it to control VeoGenie.
2. If Google Flow login/debug Chrome is not open, ask Hermes to call `open_google_flow_login` with `confirmOpenGoogleFlowLogin=true`, then finish Google login in the opened browser if needed.
3. Unzip this package to a stable folder, for example:

```text
C:\VeoGenie\veogenie-hermes-agent
```

4. Check that the local app backend is running:

```powershell
Invoke-RestMethod http://127.0.0.1:8788/health
```

Expected:

```json
{ "ok": true }
```

4. Add `mcp-config.json` to Hermes Agent's MCP configuration. If Hermes does not resolve relative `cwd` from the config file location, use `mcp-config.absolute.example.json` and replace the path with the customer's unzip path.
5. Add `HERMES_INSTRUCTIONS.md` as Hermes project/system instructions.
6. Add the `skills/` folder as Hermes knowledge/instructions if Hermes supports folder attachments. If it does not, ask Hermes to read the relevant skill files from this package before each job.
7. Restart Hermes Agent.

## Smoke Test Prompt

Use this prompt after setup:

```text
Use the VeoGenie MCP server.
Call get_mcp_capabilities, get_app_status, list_pages, and get_current_workflow.
If get_app_status is unreachable, call open_installed_app with confirmOpenApp=true, then retry get_app_status. If the app/backend is reachable but Google Flow login/debug Chrome needs to be prepared, call open_google_flow_login with confirmOpenGoogleFlowLogin=true, then poll get_command_status.
Report the active page name and node/edge count.
Do not create pages, modify nodes, import media, run nodes, export files, or call run_workflow_payload.
```

## Permission Model

The MCP server has no workflow write/run permissions by default. Hermes can inspect the app without running automation.

`open_installed_app` may launch the installed desktop app after `confirmOpenApp=true`; it cannot close, kill, restart, or run workflows. `open_google_flow_login` may launch the managed Google Flow debug login browser after `confirmOpenGoogleFlowLogin=true`; it cannot run workflows or click Generate.

Actions such as canvas edits, local media import, running nodes, and exporting media require explicit user approval and the matching session permission or environment guard. See `HERMES_INSTRUCTIONS.md`.

Do not enable every guard by default on customer machines.

## Important Notes

- This is a Hermes package, not a Codex marketplace package.
- The Codex offline package is `veogenie-codex-marketplace-<version>.zip`.
- The Hermes offline package is `veogenie-hermes-agent-<version>.zip`.
- Generated media must be verified from VeoGenie app state through `get_node_outputs` and `get_media_album`.
- `videoMerge` is supported for final merged videos, but only after two or more upstream video clips are complete.
