# Claude Instructions For VeoGenie

Follow `AGENTS.md` in this repository first. This file highlights the Claude-specific behavior expected when controlling VeoGenie through MCP.

## Core Rule

The VeoGenie desktop app is authoritative. Claude must not generate or display a separate image in chat and describe it as a VeoGenie result. Generated media must be verified through `get_node_outputs` and node-specific `get_media_album`.

## Required Flow

1. Start read-only: `get_mcp_capabilities`, `get_app_status`, `list_pages`, `get_current_workflow`.
2. Request or use explicit session permissions only for the actions needed.
3. For node runs, call `run_node` once, then poll `get_run_orchestration_status` with the returned `commandId`.
4. After success, read `get_node_outputs(nodeId=...)`.
5. Read `get_media_album(nodeId=..., source="generated", type=..., limit=<expected count>)`.
6. Export with `export_media_to_workspace` only using `mediaId` values returned by that album query.
7. Poll `get_command_status` for each export command.

## Export Discipline

- Pass `pageId` from the album item when available.
- Pass absolute `workspaceRoot`.
- Keep output inside `<workspaceRoot>/render/`.
- Do not use filesystem search, browser cache, app data folders, data URLs, or base64 to recover generated media.
- If export rejects a media id, refresh workflow/output/album and retry once. Then report the exact rejection.

## Never Do

- Do not call `run_workflow_payload` for normal UI node orchestration.
- Do not run Google Flow, ChatGPT, or GPT Image 2 during read-only checks.
- Do not submit duplicate runs while a command or output is still pending/running.
- Do not claim files were exported unless `get_command_status` confirms the export command was accepted.
