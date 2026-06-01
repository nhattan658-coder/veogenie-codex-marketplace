---
name: veogenie-result-qa
description: Verify, report, semantically judge, retry once when needed, and export VeoGenie results from the desktop app source of truth. Use after run_node or run_group, when Codex needs to confirm generated image/video/text outputs, compare media counts with resultCount, retrieve node-specific media ids, export files to workspace render/ or render/qa/, inspect whether results match the original brief, or avoid substituting chat-generated media for app results.
---

# VeoGenie Result QA

## Source Of Truth

The open VeoGenie desktop app is authoritative. Do not create or show a separate chat-generated image/video as if it came from VeoGenie.

Read `references/result-handoff-checklist.md` before reporting final results.

Read `references/semantic-result-qa.md` when the user asks to judge whether an image/video matches the original request, detect drift from the prompt, choose the best candidate, or regenerate one failed result once.

## Required Sequence

After a node or group run:

1. Poll `get_run_orchestration_status` until `summary.shouldPollAgain=false`.
2. Stop if the summary phase is `error`.
3. Call `get_node_outputs` with the exact output `nodeId`.
4. Call `get_media_album` with the exact output `nodeId`, `source="generated"`, expected `type`, and expected `limit`.
5. Compare the returned media count with `resultCount` or output history.
6. If the user wants files, export each verified `mediaId` with `export_media_to_workspace` after `project_export` permission is enabled.
7. Poll `get_command_status` for every export command.

## Semantic QA And One Retry

When semantic QA is requested:

1. Preserve the original user brief as a short checklist before judging.
2. Export candidate media to a QA subfolder under `render/`, for example `render/qa/<job-slug>/`, using `export_media_to_workspace`.
3. Inspect exported files when the environment supports that media type.
4. Score candidates with the rubric in `references/semantic-result-qa.md`.
5. If at least one candidate passes and the user did not require every result to pass, select the best passing result.
6. If no candidate passes, run the same node or group at most one more time with a targeted correction prompt.
7. Repeat technical QA and semantic QA once after retry. Do not loop.

Do not claim visual QA was performed for a video if the environment could not inspect video frames or playback.

If the user confirms that a result is correct and asks to remember the direction, or says the result is wrong and asks not to repeat the mistake, use `veogenie-project-memory` after QA. Store only durable guidance, not transient run details.

## Reporting

Report:

- Page name or id.
- Output node id.
- Verified generated media count.
- Media ids used.
- Exported file paths when export succeeds.
- `qaStatus`, `retryAttempted`, selected media id, and QA reasons when semantic QA was used.
- Rejected command messages if run/export fails.

Do not claim success if media count, node id, or export command status was not verified.
