---
name: veogenie-workflow-designer
description: Design, review, or create VeoGenie workflow recipes with correct node types, edge handles, and MCP canvas-write sequencing. Use when Codex needs to build or append workflows, connect inputs to generate nodes, route text/image/video/voice outputs, or reason about video frame, reference image, and voice ports including video component-mode connections.
---

# VeoGenie Workflow Designer

## Start

Use this skill when the task involves workflow structure, nodes, edges, or handles.

Before creating or appending a workflow:

1. Use the base `veogenie` skill to read app state.
2. Read `references/node-port-contract.md`.
3. If a voice input is involved, read `references/voice-connection-rules.md`.
4. If the user asks for a full workflow pattern, read `references/workflow-patterns.md`.

## Recipe Rules

- Always set explicit `sourceHandle` and `targetHandle` on every recipe edge.
- Do not rely on default handle inference when the target is `videoGenerate`.
- Treat `frame-start`, `frame-end`, `video-reference-image`, and `video-voice-reference` as different semantics.
- If the user asks to make a video from frames/keyframes, connect the images to `frame-start` and optionally `frame-end`; do not also connect those frame images to `video-reference-image`, and do not add voice unless requested.
- If the user asks for synchronized narration/voice with image inputs, connect all image inputs to `video-reference-image` and connect the voice to `video-voice-reference`; use `frame-start`/`frame-end` only if the user explicitly asks for exact first/last frames.
- Do not pass media URLs, data URLs, blob URLs, or base64 through recipe nodes.
- Create empty `imageReference` nodes in recipes, then use `attach_local_media_to_node` only after the page/node exists and media import permission is enabled. For user images supplied in chat, stage the attachment as a local workspace file first and use `attach_chat_image_to_node`.

## Canvas Write Flow

For a new workflow page:

1. Build a recipe with explicit handles.
2. Use `create_workflow_page` only after `canvas_write` permission is enabled.
3. Read `get_current_workflow` after the command is accepted.
4. Verify the expected nodes and edges exist.

For the current page:

1. Prefer a new page unless the user asked to modify the active page.
2. Use `append_workflow_to_current_page` with `confirmModifyCurrentPage=true`.
3. Keep the returned `rollbackToken`.
4. Verify with `get_current_workflow`.

For existing nodes on the current page:

1. Use `update_workflow_nodes` only for schema-safe node fields such as title, prompt, position, size, model, aspect ratio, result count, duration, and voice metadata.
2. Use `delete_workflow_nodes` only when the user asked to remove nodes; it deletes connected edges and group children.
3. Both tools require `canvas_write`, `confirmModifyCurrentPage=true`, and command-status polling.
4. Do not use these tools to run automation, edit generated outputs/status, delete pages, delete media, or change node ids/types.

## Run Flow

- Use `run_node` or `run_group` only after `actions` permission is enabled.
- Build a small run plan from the graph before starting: mark nodes ready only when their required direct inputs are present and upstream output dependencies are already `success`.
- Queue all ready independent output nodes with separate `run_node` calls before polling; keep each returned `commandId`.
- Poll `get_run_orchestration_status` for every queued command.
- Do not call `run_node` again for the same node while its command is queued/dispatched or output is running.
- Do not queue downstream dependent nodes until their upstream outputs exist and are verified with `get_node_outputs`.
- Prefer `run_group` when nodes are inside one group and the app should enforce internal dependencies.
- After success, use the `veogenie-result-qa` skill for output verification and export.
