# VeoGenie Agent Instructions

These instructions are for agents using the VeoGenie marketplace repository or plugin. They are intentionally outside the skill file so Codex, Claude, and other repo-aware agents can read the workflow before using MCP tools.

## Source Of Truth

- The open VeoGenie desktop app is the source of truth for workflow state and generated media.
- Do not display, synthesize, redraw, or attach a new chat-generated image as if it came from VeoGenie.
- MCP responses intentionally do not include media URLs, data URLs, blob URLs, or base64 payloads.
- If the user needs actual files, export verified `mediaId` values from `get_media_album`; do not search browser/app cache folders.

## First Calls

Always start with read-only tools:

1. `get_mcp_capabilities`
2. `get_app_status`
3. `list_pages`
4. `get_current_workflow`

Do not call `run_node`, `run_group`, canvas-write tools, import, or export during a read-only check.

## Skill Selection

- Use `veogenie` for MCP safety, read-only inspection, permissions, run/poll, result handoff, and export rules.
- Use `veogenie-workflow-designer` for workflow node/edge planning and dependency checks.
- Use `veogenie-product-ad` for product image/video ad briefs, prompt standards, and product fidelity.
- Use `veogenie-video-director` for video prompts, camera motion, frame planning, duration, and voice guidance.
- Use `veogenie-result-qa` before reporting completion or exporting generated media.
- Creative skills are guidance only; they do not enable MCP write/run/export guards.

## Permissions

Prefer session permissions when the user explicitly approves actions in chat:

```json
{
  "permissions": ["canvas_write", "media_import", "actions", "project_export"],
  "confirmGrantSessionPermissions": true,
  "approvalNote": "User approved creating a workflow, importing a local image, running nodes, and exporting verified generated media."
}
```

Use only the permissions needed for the task:

- `canvas_write`: create/append/rollback workflow pages.
- `media_import`: attach a local image file to an `imageReference` node.
- `actions`: run existing output nodes or groups.
- `project_export`: export generated media into `<workspaceRoot>/render/`.
- `media_export`: export through a native save dialog.

Never use `run_workflow_payload` unless the user/admin has explicitly enabled `VEOGENIE_MCP_ALLOW_RUN=1`. Session grants do not enable it.

## Product Image Job

Use this sequence for requests like "create 3 product images from this image and save them":

1. Call `plan_product_ad_job` or `build_product_ad_workflow_recipe`.
2. Create the workflow with `create_workflow_page`, or append only if the user asked to modify the current page.
3. Attach the user image with `attach_local_media_to_node`.
4. Run the image node with `run_node`.
5. Poll `get_run_orchestration_status` using the returned `commandId`.
6. While `summary.shouldPollAgain` is true, wait at least `nextPollAfterMs` when provided, then poll again. Do not call `run_node` again.
7. After completion, call `get_node_outputs` with the exact output `nodeId`.
8. Call `get_media_album` with the exact output `nodeId`, `source="generated"`, `type="image"`, and `limit=<expected resultCount>`.
9. Verify the returned media count matches the expected count before claiming success.
10. Export each returned `mediaId` with `export_media_to_workspace`, one media item per tool call.
11. Poll `get_command_status` for each export command until it is `accepted` or `rejected`.

## Export Rules

For `export_media_to_workspace`:

- Use a `mediaId` returned by node-specific `get_media_album`.
- Pass `pageId` from the album item when available.
- Pass absolute `workspaceRoot`.
- Use `renderDir="render"` unless the user asked for a subfolder under `render/`.
- Set `confirmWriteProjectRender=true`.
- Use stable filenames such as `product-name-1.png`, `product-name-2.png`, `product-name-3.png`.
- Keep `confirmOverwrite=false` unless the user explicitly approves overwriting.

If export is rejected:

1. Do not search `%LOCALAPPDATA%`, browser cache, IndexedDB, or app storage.
2. Refresh `get_current_workflow`.
3. Refresh `get_node_outputs(nodeId=...)`.
4. Refresh `get_media_album(nodeId=..., source="generated", type=..., limit=...)`.
5. Retry the same export once after a short delay.
6. If it still fails, report the exact rejected command message and leave the result in the VeoGenie app.

## Polling And Stop Conditions

- Do not submit duplicate runs while command status is `queued` or `dispatched`.
- Do not submit duplicate runs while an output is `running`.
- Stop if `get_run_orchestration_status` reports `phase="error"`.
- Stop if the output node reports `generationStatus="error"`.
- Do not run video until the required image/text upstream outputs are `success`.

## Reporting

Final answers should include:

- Page name or page id.
- Output node id.
- Count of verified generated media.
- Media ids used for export.
- Exported file paths when export succeeds.
- Any rejected command message if export or run fails.

Do not include a fake preview image in the final answer.
