---
name: veogenie
description: Use when Codex needs to inspect or control a locally installed VeoGenie desktop app through the bundled MCP server. Start with read-only status/page/workflow tools; only use guarded write/run/export tools when the user explicitly enabled the corresponding environment guard or granted temporary MCP session permission in chat.
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
6. Use `build_product_ad_workflow_recipe` only when planning a product ad workflow; it is read-only and only returns a recipe plus next steps.
7. Use `plan_product_ad_job` for an end-to-end product ad tool-call plan; it is read-only and does not execute the plan.
8. After a guarded `run_node` or `run_group`, use `get_run_orchestration_status` with the returned command id before deciding whether to poll again or read final outputs.

## Result Handoff

- Treat the VeoGenie desktop app as the source of truth. Do not generate, redraw, attach, or display a separate AI image in chat as if it were a VeoGenie result.
- After a run finishes, call `get_node_outputs` and then `get_media_album` with the exact output `nodeId`, `source="generated"`, and the expected `type`.
- Compare the returned media count with the node `resultCount` or `assetHistory` count before saying the job is complete.
- If the user wants the actual files outside the app, use `export_media_to_workspace` for each `mediaId` from `get_media_album` after `project_export` is enabled. Report the exported paths/media ids, not a new chat-generated preview.
- If the media cannot be verified or exported, say that directly and leave the result in the VeoGenie app.

## Guarded Tools

- If the user explicitly approves permissions in chat, call `grant_mcp_session_permissions` with the needed permissions and `confirmGrantSessionPermissions=true`. This avoids asking the user to set PowerShell env vars.
- `run_node` and `run_group` require `VEOGENIE_MCP_ALLOW_ACTIONS=1` or session permission `actions`.
- `create_workflow_page`, `append_workflow_to_current_page`, and `undo_last_mcp_canvas_write` require `VEOGENIE_MCP_ALLOW_CANVAS_WRITE=1` or session permission `canvas_write`, plus the tool-specific confirm fields.
- `export_media` requires `VEOGENIE_MCP_ALLOW_MEDIA_EXPORT=1` or session permission `media_export`, plus `confirmOpenSaveDialog=true`.
- `attach_local_media_to_node` requires `VEOGENIE_MCP_ALLOW_MEDIA_IMPORT=1` or session permission `media_import`, plus `confirmImportLocalFile=true`.
- `export_media_to_workspace` requires `VEOGENIE_MCP_ALLOW_PROJECT_EXPORT=1` or session permission `project_export`, plus `confirmWriteProjectRender=true` and an absolute `workspaceRoot`; it only writes generated media into `<workspaceRoot>/render/`.
- `run_workflow_payload` requires `VEOGENIE_MCP_ALLOW_RUN=1`.

Do not use guarded tools unless the user explicitly asked for that action and the relevant env guard or session permission is enabled. Use `revoke_mcp_session_permissions` when the user asks to turn off temporary permissions.

For node/group runs, do not call `run_workflow_payload`; use `run_node` / `run_group`, then poll `get_run_orchestration_status`. Do not submit another run while the command is `queued` / `dispatched` or the output is `running`.

## Safety

- Do not run Google Flow, ChatGPT, GPT Image 2, node/group actions, or full workflow payloads during a read-only check.
- `build_product_ad_workflow_recipe` must stay plan-only: do not treat its output as a canvas write until the user explicitly asks to create/append the workflow and the canvas-write guard is enabled.
- `plan_product_ad_job` must stay plan-only: execute only its returned guarded tool-call steps when the user asked for that action and the matching guard is enabled.
- Do not pass media URLs, base64, data URLs, or blob URLs through MCP.
- For local media import, pass only a local file path and let the desktop app read the file.
- For desktop file export, the app must open a native save dialog before writing.
- For project render export, use only `export_media_to_workspace` after the project export guard is enabled; never use it for arbitrary output paths outside `render/`.
