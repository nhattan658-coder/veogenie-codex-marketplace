# VeoGenie Agent Guide

This file is a lightweight working guide for AI agents using the VeoGenie MCP plugin. It explains the normal node roles, input wiring, voice reuse, and basic tool flow.

## Start

Before changing anything, inspect the open desktop app:

1. `get_mcp_capabilities`
2. `get_app_status`
3. `list_pages`
4. `get_current_workflow`

Use write/run/export tools only when the user asks for that action and grants the needed session permission or environment guard.

Canvas mutation tools still go through the desktop app command queue. `update_workflow_nodes` may edit only schema-safe node fields such as title, prompt, model, aspect ratio, result count, duration, position, size, and voice metadata. `delete_workflow_nodes` may remove nodes from the active page and connected edges; deleting a group also removes child nodes. These tools require `canvas_write` plus `confirmModifyCurrentPage=true`, return a rollback token, and must not be used to run Google Flow, ChatGPT, GPT Image 2, delete pages, delete media, or edit generated output/status fields.

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
```

Choose the video image port by meaning:

- `frame-start`: the image should be the first frame.
- `frame-end`: the image should be the last frame.
- `video-reference-image`: the image is a style/product/character/reference image, not a strict first or last frame.

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
2. Connect start/end frames only when the user wants exact first/last frames.
3. Connect product/style images to `video-reference-image`.
4. Connect voice to `video-voice-reference` when narration voice matters.
5. Run only after required upstream image/text nodes have completed.

## Run Scheduling

Do not serialize independent work by habit. Before running, inspect `get_current_workflow` and identify ready output nodes:

- A node is ready when all required direct inputs are present and any upstream output dependency is already `success` with the needed text/image/video asset.
- Nodes in different branches with no dependency between them can be queued in the same scheduling pass with separate `run_node` calls.
- After queuing multiple ready nodes, keep every returned `commandId` and poll each one with `get_run_orchestration_status`.
- Do not queue the same node twice while its command is `queued`/`dispatched` or its output is `running`.
- Do not queue a downstream node until the upstream node it depends on is `success` and `get_node_outputs` shows the expected output.
- Prefer `run_group` when the ready nodes are in one group and the app should enforce internal dependencies.

Example: if three `imageGenerate` nodes each use their own `textPrompt` and `imageReference`, queue all three `run_node` calls first, then poll all three. If one `videoGenerate` uses the first image output as `frame-start`, wait for that image node before running the video node.

## Reporting

When reporting results, use the app state from `get_node_outputs` and `get_media_album`. If files were exported, include the exported paths and media ids. If generation is still running or an export failed, report that state plainly.

Chat-provided input images are allowed only after they have been staged as local files under `workspaceRoot`. Do not pass image bytes, base64, data URLs, blob URLs, or remote URLs through MCP, and do not report a chat image as a VeoGenie generated result.
