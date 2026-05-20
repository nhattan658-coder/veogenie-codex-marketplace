---
name: veogenie
description: Use when Codex needs to inspect or control a locally installed VeoGenie desktop app through the bundled MCP server. Start with read-only status/page/workflow tools; only use guarded write/run/export tools when the user explicitly enabled the corresponding environment guard.
---

# VeoGenie

## Preconditions

- The user must install and open the VeoGenie desktop app.
- The local backend should answer `http://127.0.0.1:8788/health`.
- The installed MCP launcher should exist at `D:\VeoGenie Tool\veogenie-mcp.cmd`.

## Default Safe Flow

1. Call `get_mcp_capabilities`.
2. Call `get_app_status`.
3. Call `list_pages`.
4. Call `get_current_workflow` before reasoning about nodes or edges.
5. Use `get_node_outputs` or `get_media_album` for sanitized outputs.

## Guarded Tools

- `run_node` and `run_group` require `VEOGENIE_MCP_ALLOW_ACTIONS=1`.
- `create_workflow_page`, `append_workflow_to_current_page`, and `undo_last_mcp_canvas_write` require `VEOGENIE_MCP_ALLOW_CANVAS_WRITE=1` plus the tool-specific confirm fields.
- `export_media` requires `VEOGENIE_MCP_ALLOW_MEDIA_EXPORT=1` and `confirmOpenSaveDialog=true`.
- `run_workflow_payload` requires `VEOGENIE_MCP_ALLOW_RUN=1`.

Do not use guarded tools unless the user explicitly asked for that action and the relevant guard is enabled.

## Safety

- Do not run Google Flow, ChatGPT, GPT Image 2, node/group actions, or full workflow payloads during a read-only check.
- Do not pass media URLs, base64, data URLs, or blob URLs through MCP.
- For desktop file export, the app must open a native save dialog before writing.
