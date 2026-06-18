# Claude Guide For VeoGenie

Follow `AGENTS.md` first. This file keeps the same guidance short for Claude-style agents.

## Basic Flow

1. Inspect the app with `get_mcp_capabilities`, `get_app_status`, `list_pages`, and `get_current_workflow`.
2. Ask for or use only the permissions needed for the user's requested action.
3. Create or append workflow pages only when the user wants a workflow change.
4. Edit existing node fields with `update_workflow_nodes` or delete active-page nodes with `delete_workflow_nodes` only when the user asks, `canvas_write` is enabled, and `confirmModifyCurrentPage=true` is present.
5. Attach user images with `attach_local_media_to_node`. For images provided in chat, stage the attachment as a local file under `workspaceRoot`, then call `attach_chat_image_to_node` with `confirmImportChatImage=true`.
6. Run nodes/groups with `run_node` or `run_group`.
7. Poll with `get_run_orchestration_status`.
8. Read final state with `get_node_outputs` and `get_media_album`.
9. Export with `export_media_to_workspace` when the user wants files in the project.

`update_workflow_nodes` and `delete_workflow_nodes` do not run Google Flow, ChatGPT, GPT Image 2, or raw `/workflow/run`. Do not use them to edit generated output/status fields, delete pages, or delete media files.

Use `veogenie-model-selector` before choosing or updating model settings. Prefer GPT Image 2 for realistic images/storyboards, Nano Banana Pro or Nano Banana 2 at `2K`/`4K` for high-quality images, Omni Flash for the most realistic video, and Veo 3.1 models for normal video.

Use `veogenie-ai-assistant-prompt-writer` to choose prompt-authoring mode. Prefer Codex-direct prompts; use `aiAssistant` / `Tro Ly AI` only when prompt generation must be dynamic, reusable, grounded by runtime inputs, produce selectable variants, or is explicitly requested inside the workflow. Verify assistant text before downstream generation.

Use `veogenie-image-to-video-input-planner` when a video should be created from a generated still, fashion look, product hero, storyboard frame, or exact visual anchor. Generate the anchor image first when it controls the look, then connect only necessary inputs to `videoGenerate`; omit redundant clothing/prop/style refs already visible in that anchor.

Use `veogenie-continuity-asset-planner` before multi-scene videos when important characters, products, props, wardrobe, locations, or style references must stay consistent. If the script adds characters that were not supplied by the user, create those character reference images before scene videos and route them through `video-reference-image`.

Use `veogenie-viral-video-producer` for hook-driven scripts, natural dialogue, and multi-scene short videos. Create one video node per scene and, when the user wants one final combined file, connect ordered finished clips into a `videoMerge` node.

## Project Memory

When the user explicitly says a VeoGenie result or process is right/wrong and asks to remember it, use `veogenie-project-memory` to update project memory files. Prefer existing `AGENTS.md`, `CLAUDE.md`, `DESIGN.md`, and `BUSINESS_RULES.md`; create missing files only after the user approved the memory update.

Store only durable rules: agent process in `AGENTS.md`, short companion guidance in `CLAUDE.md`, visual/style preferences in `DESIGN.md`, and domain or must-not-repeat rules in `BUSINESS_RULES.md`. Do not write raw media, base64, private data, or temporary paths. Do not update memory silently after every run.

## Node Roles

- `textPrompt`: prompt text.
- `imageReference`: local/product/reference image.
- `voiceReference`: reusable built-in voice preset for video. Use an exact preset name in `voiceName`; put descriptive tone notes in `voiceDescription`.
- `aiAssistant`: generated text for later nodes.
- `imageGenerate`: image output.
- `videoGenerate`: video output.
- `videoMerge`: local lossless merge output for two or more finished video clips.

## Useful Connections

```text
textPrompt:text -> imageGenerate:text
imageReference:image -> imageGenerate:image

textPrompt:text -> videoGenerate:text
aiAssistant:generatedText -> videoGenerate:text

imageReference:image -> videoGenerate:frame-start
imageReference:image -> videoGenerate:frame-end
imageReference:image -> videoGenerate:video-reference-image

imageGenerate:generatedAsset -> videoGenerate:frame-start
imageGenerate:generatedAsset -> videoGenerate:frame-end
imageGenerate:generatedAsset -> videoGenerate:video-reference-image

voiceReference:voice -> videoGenerate:video-voice-reference

videoGenerate:video -> videoMerge:video
videoMerge:video -> videoMerge:video
```

Use `frame-start` for the first frame, `frame-end` for the last frame, and `video-reference-image` for product/style/character references.

If the user asks for a video from frames or keyframes, route images to `frame-start` and optionally `frame-end`; do not also route those frame images to `video-reference-image`, and do not add voice unless requested.

If the user asks for synchronized voice, narration, or shared speaker voice, route image inputs to `video-reference-image` and route the voice to `video-voice-reference`. Use `frame-start`/`frame-end` only when the user explicitly asks for exact first/last frames.

## Shared Voice

For many videos with the same narration voice, create one `voiceReference` node with an exact built-in preset name and connect it to every `videoGenerate:video-voice-reference` input. Keep each video's prompt and frame inputs separate unless the user wants them shared too.

## Video Merge

Use `videoMerge` only after the source clips are generated. Connect video outputs to `videoMerge:video` in the desired order, wait for all source clips to be `success`, then run/export the merge node as the final combined video.

## Run Scheduling

Do not wait for one independent branch to finish before starting another. Inspect the workflow, queue all ready independent output nodes with separate `run_node` calls, keep each `commandId`, and poll each with `get_run_orchestration_status`.

Only wait when there is a real dependency: a downstream node must not run until the upstream node is `success` and has the expected text/image/video output. A `videoMerge` node must wait for at least two connected video outputs to finish. Never queue the same node twice while its command is queued/dispatched or its output is running. Prefer `run_group` when a group should enforce dependencies internally.

## Result Handoff

Report results from VeoGenie state, not from a separate chat-generated preview. Use media ids from `get_media_album`; if export succeeds, report the file paths.

Chat-provided images are input references only after staging to a local file. Do not pass raw media, base64, data URLs, blob URLs, or remote URLs through MCP.
