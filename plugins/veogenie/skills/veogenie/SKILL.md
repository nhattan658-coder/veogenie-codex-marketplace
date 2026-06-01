---
name: veogenie
description: Use when Codex needs to inspect or control a locally installed VeoGenie desktop app through the bundled MCP server. Covers basic app startup, node roles, permissions, workflow runs, parallel-ready node scheduling, result lookup, and export handoff.
---

# VeoGenie

## Preconditions

- The user must install and open the VeoGenie desktop app.
- The local backend should answer `http://127.0.0.1:8788/health`.
- The installed MCP launcher should exist at `D:\VeoGenie Tool\veogenie-mcp.cmd`.

## Basic Flow

1. Call `get_mcp_capabilities`.
2. Call `get_app_status`.
3. Call `list_pages`.
4. Call `get_current_workflow` before reasoning about nodes or edges.
5. Use `get_node_outputs` or `get_media_album` for sanitized outputs.
6. Use `build_product_ad_workflow_recipe` only when planning a product ad workflow; it is read-only and only returns a recipe plus next steps.
7. Use `plan_product_ad_job` for an end-to-end product ad tool-call plan; it is read-only and does not execute the plan.
8. After a guarded `run_node` or `run_group`, use `get_run_orchestration_status` with the returned command id before deciding whether to poll again or read final outputs.

## Node And Skill Helpers

- Use `veogenie-workflow-designer` when creating or appending workflow recipes, choosing node types, or connecting text/image/video/voice ports. It contains the authoritative port contract for `frame-start`, `frame-end`, `video-reference-image`, and `video-voice-reference`.
- Use `veogenie-video-director` when writing video prompts, spoken lines, voice tone, camera direction, or model-aware video instructions.
- Use `veogenie-product-ad` when planning product image/video ad workflows.
- Use `veogenie-result-qa` when the user asks to inspect generated results or export files.
- Use `veogenie-project-memory` when the user says a VeoGenie result or workflow was right/wrong and asks the agent to remember, avoid, apply next time, or update project rules.

Common node roles:

- `textPrompt`: prompt text.
- `imageReference`: local/product/reference image.
- `voiceReference`: reusable built-in voice preset for video. Use an exact preset name in `voiceName`; put tone notes in `voiceDescription`.
- `aiAssistant`: generated text for later nodes.
- `imageGenerate`: image output.
- `videoGenerate`: video output.

Common video inputs:

```text
textPrompt:text -> videoGenerate:text
aiAssistant:generatedText -> videoGenerate:text
imageReference:image -> videoGenerate:frame-start
imageReference:image -> videoGenerate:frame-end
imageReference:image -> videoGenerate:video-reference-image
voiceReference:voice -> videoGenerate:video-voice-reference
```

For video-from-frame/keyframe requests, route images to `frame-start` and optional `frame-end`; do not also route the same frame images to `video-reference-image`.

For synchronized voice or narration requests, route visual image inputs to `video-reference-image` and route the voice to `video-voice-reference`. Use frame ports in that workflow only when the user explicitly asked for exact first/last frames.

For several videos with the same voice, create one `voiceReference` node with an exact built-in preset name and connect it to each `videoGenerate:video-voice-reference` input.

## Result Handoff

- Use the VeoGenie desktop app state for result reporting.
- After a run finishes, call `get_node_outputs` and then `get_media_album` with the exact output `nodeId`, `source="generated"`, and the expected `type`.
- If the user wants the actual files outside the app, use `export_media_to_workspace` for each `mediaId` from `get_media_album` after `project_export` is enabled. Report the exported paths/media ids, not a new chat-generated preview.
- If the media cannot be verified or exported, say that directly and leave the result in the VeoGenie app.

## Run Scheduling

- Before running, read `get_current_workflow` and identify output nodes whose required direct inputs are already present.
- Queue all ready independent branches in the same pass with separate `run_node` calls. Keep each returned `commandId`.
- Poll every queued command with `get_run_orchestration_status`; do not block on one independent node before starting another.
- A downstream node is not ready until each upstream output it uses is `success` and `get_node_outputs` shows the expected text/image/video asset.
- Do not queue the same node twice while its command is `queued`/`dispatched` or its output is `running`.
- Prefer `run_group` when nodes are inside one group and the desktop app should enforce dependency order.

## Guarded Tools

- If the user explicitly approves permissions in chat, call `grant_mcp_session_permissions` with the needed permissions and `confirmGrantSessionPermissions=true`. This avoids asking the user to set PowerShell env vars.
- `run_node` and `run_group` require `VEOGENIE_MCP_ALLOW_ACTIONS=1` or session permission `actions`.
- `create_workflow_page`, `append_workflow_to_current_page`, `update_workflow_nodes`, `delete_workflow_nodes`, and `undo_last_mcp_canvas_write` require `VEOGENIE_MCP_ALLOW_CANVAS_WRITE=1` or session permission `canvas_write`, plus the tool-specific confirm fields.
- `export_media` requires `VEOGENIE_MCP_ALLOW_MEDIA_EXPORT=1` or session permission `media_export`, plus `confirmOpenSaveDialog=true`.
- `attach_local_media_to_node` requires `VEOGENIE_MCP_ALLOW_MEDIA_IMPORT=1` or session permission `media_import`, plus `confirmImportLocalFile=true`.
- `attach_chat_image_to_node` requires `VEOGENIE_MCP_ALLOW_MEDIA_IMPORT=1` or session permission `media_import`, plus `confirmImportChatImage=true`; use it only after the agent has staged the user's chat image as a local file under `workspaceRoot`.
- `export_media_to_workspace` requires `VEOGENIE_MCP_ALLOW_PROJECT_EXPORT=1` or session permission `project_export`, plus `confirmWriteProjectRender=true` and an absolute `workspaceRoot`; it only writes generated media into `<workspaceRoot>/render/`.
- `run_workflow_payload` requires `VEOGENIE_MCP_ALLOW_RUN=1`.

Do not use guarded tools unless the user explicitly asked for that action and the relevant env guard or session permission is enabled. Use `revoke_mcp_session_permissions` when the user asks to turn off temporary permissions.

For node/group runs, do not call `run_workflow_payload`; use `run_node` / `run_group`, then poll `get_run_orchestration_status`. Do not submit a duplicate run for the same node or dependent downstream branch while its command is `queued` / `dispatched` or its output is `running`.

## Safety

- Do not run Google Flow, ChatGPT, GPT Image 2, node/group actions, or full workflow payloads during a read-only check.
- `build_product_ad_workflow_recipe` must stay plan-only: do not treat its output as a canvas write until the user explicitly asks to create/append the workflow and the canvas-write guard is enabled.
- `plan_product_ad_job` must stay plan-only: execute only its returned guarded tool-call steps when the user asked for that action and the matching guard is enabled.
- Use `update_workflow_nodes` only for schema-safe node fields such as title, prompt, model, aspect ratio, result count, duration, position, or voice metadata. It must not edit generated outputs/status, media raw/base64, run nonce, or automation internals.
- Use `delete_workflow_nodes` only when the user asked to remove nodes from the active page. It deletes connected edges and group children, but not pages or media files.
- Do not pass media URLs, base64, data URLs, or blob URLs through MCP.
- For local media import, pass only a local file path and let the desktop app read the file.
- For chat-provided input images, save or stage the attachment as a local file in the workspace first, then call `attach_chat_image_to_node`; never pass raw chat media through MCP.
- For desktop file export, the app must open a native save dialog before writing.
- For project render export, use only `export_media_to_workspace` after the project export guard is enabled; never use it for arbitrary output paths outside `render/`.
- Do not silently update the user's `AGENTS.md`, `CLAUDE.md`, `DESIGN.md`, or `BUSINESS_RULES.md` after every run. Update project memory only after explicit user feedback or approval.
