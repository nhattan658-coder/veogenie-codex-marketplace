# VeoGenie Business Rules For AI Agents

This file defines the mandatory operating rules for AI agents controlling the installed VeoGenie desktop app through the public Codex plugin and MCP tools.

## Authority

- Treat the open VeoGenie desktop app as the source of truth for pages, nodes, edges, outputs, media ids, and exportable results.
- Do not invent node ids, page ids, media ids, handles, output counts, or exported paths.
- Do not display, synthesize, redraw, or attach a new chat-generated image/video as if it came from VeoGenie.
- MCP responses intentionally do not expose media URLs, data URLs, blob URLs, or base64 payloads.

## Startup

- Start every session with read-only inspection:
  1. `get_mcp_capabilities`
  2. `get_app_status`
  3. `list_pages`
  4. `get_current_workflow`
- Do not call run, canvas-write, import, export, or raw payload tools during a read-only check.
- If the app/backend is not reachable, report that state instead of trying to modify files or browser cache.

## Permissions

- Keep plugin operation read-only by default.
- Use `grant_mcp_session_permissions` only after the user explicitly approves the needed actions in chat.
- Request only the minimum permissions needed:
  - `canvas_write` for create/append/rollback workflow pages.
  - `media_import` for local image import into an `imageReference` node.
  - `actions` for `run_node` or `run_group`.
  - `project_export` for writing generated media into `<workspaceRoot>/render/`.
  - `media_export` for native save-dialog export.
- Never use `run_workflow_payload` unless the user/admin explicitly enabled `VEOGENIE_MCP_ALLOW_RUN=1`. Session grants do not enable it.

## Workflow Authoring

- Prefer creating a new page with `create_workflow_page` unless the user explicitly asks to modify the current page.
- Use `append_workflow_to_current_page` only with `confirmModifyCurrentPage=true`; keep and report the rollback token.
- Never delete pages, delete media, overwrite existing nodes, or rewrite the current page unless a dedicated guarded tool explicitly supports that operation.
- After create/append, read `get_current_workflow` again and verify the expected page, node ids, edges, and handles exist.

## Port And Edge Rules

- Every workflow recipe edge must include explicit `sourceHandle` and `targetHandle`.
- Do not rely on default ports.
- Read the `veogenie-workflow-designer` node port contract before writing or editing recipes.
- Valid video edge meanings include:
  - text prompt or assistant text -> `videoGenerate:text`
  - first/start frame -> `videoGenerate:frame-start`
  - last/end frame -> `videoGenerate:frame-end`
  - general video reference images -> `videoGenerate:video-reference-image`
  - voice reference -> `videoGenerate:video-voice-reference`
- The only valid voice edge is:

```text
voiceReference:voice -> videoGenerate:video-voice-reference
```

- Do not connect voice to text, frame, image, or generic reference-image ports.
- If a human is manually connecting and the video voice port is hidden, switch `Tao Video` to component/input view before connecting the voice.
- Do not treat a general `imageReference` as a start or end frame unless the user request or workflow plan clearly says so.

## Input Scope

- Output nodes should use only directly connected inputs.
- Do not pull all upstream history or unrelated generated assets into a node.
- When using a generated image downstream, use the node's current selected output, not an arbitrary older gallery item.
- If the user request is ambiguous about whether an image should be a frame, a reference image, or a product input, choose the safest explicit mapping and state it, or ask before running.

## Running Nodes And Groups

- Use `run_node` or `run_group` for normal UI orchestration. Do not use raw workflow payloads for ordinary agent jobs.
- Do not run video until required upstream text/image dependencies are successful.
- After `run_node` or `run_group`, poll `get_command_status` or `get_run_orchestration_status` with the returned command id.
- Do not submit another run while the command is `queued` or `dispatched`, or while any target output is `running`.
- Stop and report if orchestration status or node output reports an error.

## Result Verification

- After a run completes, call `get_node_outputs` with the exact output node id.
- Then call `get_media_album` with the exact output node id, `source="generated"`, the expected media `type`, and the expected `limit`.
- Compare returned media count with `resultCount` or the generated output history before claiming success.
- Use only `mediaId` values returned by the node-specific album query for export.

## Export

- Use `export_media_to_workspace` only for generated media ids returned by `get_media_album`.
- Keep project exports inside `<workspaceRoot>/render/`.
- Pass `confirmWriteProjectRender=true`, absolute `workspaceRoot`, and `pageId` when the album item provides one.
- Do not overwrite existing files unless the user explicitly approved overwrite and the request uses `confirmOverwrite=true`.
- After every export command, poll `get_command_status`.
- If export rejects a media id, refresh workflow/output/album state and retry the same export at most once.
- Never search `%LOCALAPPDATA%`, browser cache, IndexedDB, app storage, temp folders, or Google/ChatGPT browser sessions for generated media.

## Semantic QA And Retry

- When the user asks the agent to judge output quality, preserve the original user brief as the evaluation checklist.
- Complete technical verification before semantic QA.
- Export candidates to `render/qa/<job-slug>/` with `export_media_to_workspace`.
- Inspect exported files only when the local environment supports that media type.
- Do not claim visual QA if image/video content was not actually inspectable.
- Score candidates as `pass`, `partial`, or `fail` against the original brief.
- If at least one candidate passes and the user did not require every result to pass, select the best passing candidate and do not rerun.
- If all candidates fail, retry the same node or group at most once with a targeted correction prompt.
- After retry, repeat technical verification and semantic QA once, then report the best verified result or the failure.

## Reporting

- Final reports must include the page name or id, output node id, verified media count, media ids, exported paths when export succeeds, and any rejected command messages.
- When semantic QA was used, include `qaStatus`, `retryAttempted`, selected `mediaId`, QA export path when available, and concise QA reasons.
- Do not claim success if node id, media count, source of truth, or export command status was not verified.
