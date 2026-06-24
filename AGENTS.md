# VeoGenie Agent Guide

This file is a lightweight working guide for AI agents using the VeoGenie MCP plugin. It explains the normal node roles, input wiring, voice reuse, and basic tool flow.

## Start

Before changing anything, inspect the open desktop app:

1. `get_mcp_capabilities`
2. `get_app_status`
3. If the backend is unreachable and the user asked the agent to control/open VeoGenie, call `open_installed_app` with `confirmOpenApp=true`, then retry `get_app_status`.
4. If the user asked the agent to prepare Google Flow login/browser access, call `open_google_flow_login` with `confirmOpenGoogleFlowLogin=true`, then poll `get_command_status`.
5. `list_pages`
6. `get_current_workflow`

Use write/run/export tools only when the user asks for that action and grants the needed session permission or environment guard.

`open_installed_app` is open-only. Do not close, kill, or restart the VeoGenie desktop app from MCP.

`open_google_flow_login` only opens the managed Chrome/Edge debug browser for Google Flow login. It does not run Google Flow automation or click Generate.

Canvas mutation tools still go through the desktop app command queue. `update_workflow_nodes` may edit only schema-safe node fields such as title, prompt, model, aspect ratio, result count, duration, geminiThinkingLevel, position, size, and voice metadata. `delete_workflow_nodes` may remove nodes from the active page and connected edges; deleting a group also removes child nodes. These tools require `canvas_write` plus `confirmModifyCurrentPage=true`, return a rollback token, and must not be used to run Google Flow, ChatGPT, GPT Image 2, delete pages, delete media, or edit generated output/status fields.

Use `veogenie-model-selector` before choosing or updating model settings on `imageGenerate` or `videoGenerate` nodes. Default guidance: GPT Image 2 for realistic images/storyboards, Nano Banana Pro or Nano Banana 2 at `2K`/`4K` for high-quality images, Omni Flash for the most realistic video, Veo 3.1 models for normal video, and Gemini web video models only when the user explicitly wants the Gemini web flow.

For Gemini web video models (`gemini-3.1-flash-lite-video`, `gemini-3.5-flash-video`, `gemini-3.1-pro-video`), set `geminiThinkingLevel` to `standard` for simple/fast prompts and `extended` for complex, product-fidelity, or high-constraint prompts. Do not set `geminiThinkingLevel` on Google Flow/labs models.

Use `veogenie-ai-assistant-prompt-writer` when deciding how prompts should be authored. Let Codex write final prompts directly by default. Add `aiAssistant` / `Tro Ly AI` only for dynamic, reusable, runtime-grounded, variant-producing, or explicitly requested prompt-writing stages; verify its text output before running downstream image/video nodes.

Use `veogenie-image-to-video-input-planner` when a video should be grounded by a generated still, product hero, fashion look, storyboard frame, or exact visual anchor. Create the image first when it controls the final look, then connect only the minimal inputs to `videoGenerate`; omit redundant wardrobe/prop/style refs if the anchor image already contains them clearly.

Use `veogenie-continuity-asset-planner` before multi-scene videos when the script has missing or recurring characters, wardrobe, props/products, locations, style refs, or shared voice inputs. If the user supplied only one character but the script adds other important characters, create those character reference images first, then route them to every relevant scene through `video-reference-image`.

Use `veogenie-viral-video-producer` when the user wants a hook-driven short video, viral-style script, natural spoken dialogue, or multiple clips that form one story. Build one `videoGenerate` node per scene, keep dialogue human and speakable, connect one shared `voiceReference` to all scenes when voice consistency matters, and connect ordered finished clips into a `videoMerge` node when the user wants one final combined video.

## Project Memory From Feedback

When the user says a VeoGenie result, workflow, prompt, or design is right or wrong and asks to remember it, update the user's project memory files instead of relying on chat history.

Use `veogenie-project-memory` for this work. Prefer existing files and create missing files only when the user approved the memory update:

- `AGENTS.md`: agent process and workflow rules for the user's project.
- `CLAUDE.md`: short companion rules for Claude-style agents.
- `DESIGN.md`: visual style, brand direction, prompt style, approved and rejected looks.
- `BUSINESS_RULES.md`: durable domain rules, product constraints, and must-not-repeat mistakes.

Do not update these files silently after every run. Only store durable guidance from explicit feedback such as "remember this", "next time do this", "this is correct", or "do not do this again". Keep entries concise, avoid raw media/base64/private data, preserve existing content, and report which files changed.

## Node Basics

- `textPrompt`: stores text instructions. Connect it to image/video/assistant nodes when the prompt should drive generation.
- `imageReference`: stores a user or product image. Use it as an image input, video frame, or general video reference depending on the target port.
- `voiceReference` / `Giong Noi`: stores a built-in voice preset. Use it only for video voice input. Put the exact preset name in `voiceName`; do not put a free-text description such as "young soft female voice" in `voiceName`.
- `aiAssistant` / `Tro Ly AI`: produces text. Use its generated text as a prompt for downstream image or video nodes.
- `imageGenerate` / `Tao Anh`: creates images from text and optional image references.
- `videoGenerate` / `Tao Video`: creates videos from text, optional start/end frames, optional reference images, and optional voice.
- `videoMerge` / `Ghép Video`: locally merges two or more finished video outputs in edge order without re-encoding when compatible.
- `group`: runs a set of connected nodes while respecting their dependencies.

## Common Connections

Use explicit handles when creating recipes:

```text
textPrompt:text -> imageGenerate:text
imageReference:image -> imageGenerate:image

textPrompt:text -> videoGenerate:text
aiAssistant:generatedText -> videoGenerate:text

imageReference:image -> videoGenerate:frame-start
imageGenerate:generatedAsset -> videoGenerate:frame-start

imageReference:image -> videoGenerate:frame-end
imageGenerate:generatedAsset -> videoGenerate:frame-end

imageReference:image -> videoGenerate:video-reference-image
imageGenerate:generatedAsset -> videoGenerate:video-reference-image

voiceReference:voice -> videoGenerate:video-voice-reference

videoGenerate:video -> videoMerge:video
videoMerge:video -> videoMerge:video
```

Choose the video image port by meaning:

- `frame-start`: the image should be the first frame.
- `frame-end`: the image should be the last frame.
- `video-reference-image`: the image is a style/product/character/reference image, not a strict first or last frame.

For "make a video from this frame/keyframe" requests, connect the provided frame image to `frame-start`, and connect a second ending frame to `frame-end` when provided. Do not also connect those frame images to `video-reference-image`, and do not add voice unless the user asked for voice.

For synchronized voice, narration, or shared speaker voice requests, connect every visual image input to `video-reference-image` by default and connect the `voiceReference` node to `video-voice-reference`. Use `frame-start` or `frame-end` in the same workflow only when the user explicitly asks for exact first or last frames.

## One Voice For Multiple Videos

To keep several videos on the same voice:

1. Create one `voiceReference` node.
2. Select one exact built-in preset in that node. Put descriptive tone notes in `voiceDescription`, not `voiceName`.
3. Connect the same voice output to every target video:

```text
voiceReference:voice -> videoGenerate:video-voice-reference
voiceReference:voice -> videoGenerate:video-voice-reference
voiceReference:voice -> videoGenerate:video-voice-reference
```

Each `videoGenerate` node can still have its own text prompt, start frame, end frame, and reference images. The shared voice node keeps the spoken voice consistent across the batch.

## Merge Multiple Clips

Use `videoMerge` when the user wants one final combined video from several generated clips.

1. Create one `videoMerge` node after the scene clips.
2. Connect each source clip in the intended order:

```text
videoGenerate:video -> videoMerge:video
videoGenerate:video -> videoMerge:video
videoGenerate:video -> videoMerge:video
```

3. Do not run `videoMerge` until at least two connected upstream `videoGenerate` or `videoMerge` nodes are `success` and each has a generated video asset.
4. Report/export the final media from the `videoMerge` node, not from the individual clips, when the user asked for one combined file.

## Basic Workflows

For a product image job:

1. Create or plan a workflow with `build_product_ad_workflow_recipe` or `plan_product_ad_job`.
2. Create a new page with `create_workflow_page`, or append only when the user wants the current page changed.
3. Attach local product images with `attach_local_media_to_node`. If the user provided an image in the AI Agent chat, first stage that attachment as a local file under the workspace, then use `attach_chat_image_to_node` with `confirmImportChatImage=true`.
4. Run `imageGenerate` nodes with `run_node` or run the whole group with `run_group`.
5. Poll with `get_run_orchestration_status`.
6. Read outputs with `get_node_outputs` and media metadata with `get_media_album`.
7. Export files with `export_media_to_workspace` when the user wants files in the workspace.

For a video job:

1. Connect text into `videoGenerate:text`.
2. If the video depends on a precise visual look, generate the anchor image first, especially for fashion/product/storyboard/keyframe clips.
3. For multi-scene videos, make an asset manifest first. Generate or attach missing reusable characters, props/products, wardrobe, or locations before the scene videos.
4. Connect start/end frames only when the user wants exact first/last frames.
5. Connect product/style/character/location references to `video-reference-image` only when they add necessary information not already present in the anchor image.
6. Connect voice to `video-voice-reference` when narration voice matters.
7. Add `videoMerge` after scene clips only when one combined video is requested.
8. Run only after required upstream image/text/video nodes have completed.

## Run Scheduling

Do not serialize independent work by habit. Before running, inspect `get_current_workflow` and identify ready output nodes:

- A node is ready when all required direct inputs are present and any upstream output dependency is already `success` with the needed text/image/video asset.
- Nodes in different branches with no dependency between them can be queued in the same scheduling pass with separate `run_node` calls.
- After queuing multiple ready nodes, keep every returned `commandId` and poll each one with `get_run_orchestration_status`.
- Do not queue the same node twice while its command is `queued`/`dispatched` or its output is `running`.
- Do not queue a downstream node until the upstream node it depends on is `success` and `get_node_outputs` shows the expected output. For `videoMerge`, all connected source video nodes must be complete first.
- Prefer `run_group` when the ready nodes are in one group and the app should enforce internal dependencies.

Example: if three `imageGenerate` nodes each use their own `textPrompt` and `imageReference`, queue all three `run_node` calls first, then poll all three. If one `videoGenerate` uses the first image output as `frame-start`, wait for that image node before running the video node.

## Reporting

When reporting results, use the app state from `get_node_outputs` and `get_media_album`. If files were exported, include the exported paths and media ids. If generation is still running or an export failed, report that state plainly.

Chat-provided input images are allowed only after they have been staged as local files under `workspaceRoot`. Do not pass image bytes, base64, data URLs, blob URLs, or remote URLs through MCP, and do not report a chat image as a VeoGenie generated result.
