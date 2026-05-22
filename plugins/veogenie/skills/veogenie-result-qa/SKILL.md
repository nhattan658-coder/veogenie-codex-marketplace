---
name: veogenie-result-qa
description: Verify VeoGenie generated results, media album metadata, and exports before reporting completion. Use when Codex needs to review generated images/videos/text, compare outputs with the user brief, check node-specific media counts, export verified media ids, or diagnose incomplete VeoGenie result handoff.
---

# VeoGenie Result QA

## Scope

Use this skill after a workflow run, export request, or result review. Use the core `veogenie` skill for the exact MCP calls and guarded export permissions.

## Default Process

1. Read the current workflow or target page state.
2. Read the target output node with `get_node_outputs`.
3. Read `get_media_album` with the exact output `nodeId`, `source="generated"`, expected `type`, and expected limit.
4. Compare returned media count with `resultCount` or the node's asset history.
5. If files are requested, export each verified `mediaId` with the appropriate guarded export tool.
6. Poll `get_command_status` for each export command.
7. Report only app-verified media ids, exported paths, node ids, and any rejected command messages.

## Never Substitute Results

- Do not generate, redraw, or attach a separate chat image as if it came from VeoGenie.
- Do not report success from a recipe, plan, or prompt alone.
- Do not search browser cache, app storage, IndexedDB, or temp folders for media.
- Do not use media URLs, base64, blob URLs, or data URLs as a handoff path.

## Creative Quality Review

When the user asks whether results are good, check:

- Alignment with the original brief.
- Product or subject fidelity.
- Composition and crop safety for the requested aspect ratio.
- Readability of labels, logos, and important product features.
- Absence of unwanted text, duplicate products, warped shapes, or wrong backgrounds.
- For video: subject visibility, motion coherence, stable lighting, and usable opening/ending frames.

## Failure Handling

- If the media count is short, say exactly which node/count is incomplete and avoid claiming completion.
- If export is rejected, refresh workflow, node output, and album metadata, then retry the same export once.
- If the retry fails, report the rejected command message and leave the result in the app.
- If an output node is still running, continue polling with `get_run_orchestration_status`; do not submit a duplicate run.

## References

Read `references/result-handoff-checklist.md` for the final reporting and export checklist.
