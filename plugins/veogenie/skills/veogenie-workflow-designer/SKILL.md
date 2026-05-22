---
name: veogenie-workflow-designer
description: Design, inspect, or improve VeoGenie workflows before creating or running them. Use when Codex needs to convert a creative brief into safe VeoGenie nodes and edges, choose image/video/assistant nodes, validate dependencies and handles, or review a workflow plan for quality without bypassing MCP guards.
---

# VeoGenie Workflow Designer

## Scope

Use this skill to plan the workflow shape. Use the core `veogenie` skill for MCP calls, permissions, run/poll behavior, exports, and result handoff.

## Default Process

1. Identify the user's final deliverable: image set, video, text prompt, product ad, campaign concept, or workflow review.
2. Decide whether the task is plan-only or app-control. For app-control, start with the core `veogenie` read-only flow before proposing edits.
3. Choose the smallest workflow that can produce the requested output.
4. Validate every dependency before creating or running the workflow.
5. Use guarded MCP write/run/export tools only when the user explicitly asks for that action and the core `veogenie` permission rules are satisfied.

## Node Contract

- Use `textPrompt` for written direction and prompt text.
- Use `imageReference` for uploaded or local reference images.
- Use `aiAssistant` when a workflow needs reusable script, prompt rewrite, shot list, or structured copy before image/video generation.
- Use `imageGenerate` for final or intermediate images.
- Use `videoGenerate` only after required text and frame/reference image dependencies are ready.
- Use `voiceReference` only for video voice guidance, following the current voice rules from the app.
- Do not create, connect, or run `characterReference` / `Nhan Vat` while the app/MCP capabilities report it as disabled or locked.

## Handle Rules

- Connect text to text inputs only.
- Connect product/reference images to image inputs only.
- Connect video start and end frames to the dedicated frame handles, not to generic reference handles.
- Connect additional video visual references to `video-reference-image`.
- Connect voice input to `video-voice-reference`.
- Never mix `character-reference` with image, frame, video-reference, or voice handles.

## Recipe Standards

- Keep node ids stable, lowercase, and readable.
- Put the input/reference nodes on the left, generation nodes on the right, and assistant/planning nodes between them.
- Prefer one clear text prompt per output branch.
- Set `resultCount` deliberately: use `1` for validation, `2-4` for variant exploration.
- Set aspect ratio from the user's delivery channel. Default to `9:16` for short-form ads unless the user asks otherwise.
- Do not include media URLs, base64, blob URLs, or data URLs in workflow recipes.

## References

Read `references/workflow-patterns.md` when choosing a workflow shape or checking dependency order.
