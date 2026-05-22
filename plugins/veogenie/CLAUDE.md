# Claude Instructions For VeoGenie

Follow `AGENTS.md` and `BUSINESS_RULES.md` in this repository first. `BUSINESS_RULES.md` is the mandatory rule set for MCP permissions, workflow ports, run/poll behavior, result verification, export, and semantic QA. This file highlights the Claude-specific behavior expected when controlling VeoGenie through MCP.

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
8. If semantic QA is requested, export candidates to `render/qa/<job-slug>/`, inspect the exported files when possible, and judge against the original brief.

## Workflow Ports

When creating or editing recipes, use the workflow designer skill/reference contract if available. Always set explicit `sourceHandle` and `targetHandle`.

Voice input must use:

```text
voiceReference:voice -> videoGenerate:video-voice-reference
```

Do not connect voice to text, frame, or reference-image ports. If a human connects manually and the video voice port is hidden, switch `Tao Video` to component/input view before connecting.

## Export Discipline

- Pass `pageId` from the album item when available.
- Pass absolute `workspaceRoot`.
- Keep output inside `<workspaceRoot>/render/`.
- Use `render/qa/<job-slug>/` for candidate files exported only to inspect prompt alignment before final handoff.
- Do not use filesystem search, browser cache, app data folders, data URLs, or base64 to recover generated media.
- If export rejects a media id, refresh workflow/output/album and retry once. Then report the exact rejection.

## Semantic QA And Retry

- Preserve the original user brief as the judging checklist.
- Judge exported candidates as `pass`, `partial`, or `fail` for prompt alignment, required elements, identity/product consistency, style, technical quality, and forbidden elements.
- If at least one candidate passes, select it and do not rerun.
- If no candidate passes, rerun the same node or group at most once with a targeted correction prompt.
- Do not claim visual semantic QA for a video if playback or frame inspection was not available.
- Report `qaStatus`, `retryAttempted`, selected `mediaId`, QA export path, and concise QA reasons.

## Never Do

- Do not call `run_workflow_payload` for normal UI node orchestration.
- Do not run Google Flow, ChatGPT, or GPT Image 2 during read-only checks.
- Do not submit duplicate runs while a command or output is still pending/running.
- Do not claim files were exported unless `get_command_status` confirms the export command was accepted.
