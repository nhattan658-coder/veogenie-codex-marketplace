---
name: veogenie-video-director
description: Write and refine high-quality VeoGenie video prompts for Google Flow video generation. Use when Codex needs to direct scenes, camera motion, identity preservation, product or UGC ads, spoken lines, voice tone, frame/reference image usage, model-aware duration/aspect choices, or video prompt QA before running a videoGenerate node.
---

# VeoGenie Video Director

## Start

Use this skill when the user asks for video quality, video script, video prompt, UGC ad direction, voice tone, or scene/camera planning.

Read `references/video-prompt-rubric.md` before writing the final prompt.

If the task also requires creating or connecting workflow nodes, use `veogenie-workflow-designer` and its port contract.

## Prompt Workflow

1. Identify the output format: product ad, UGC, cinematic, tutorial, demo, before/after, or story.
2. Identify source inputs: prompt text, start frame, end frame, reference images, voice reference.
3. Write one clear production brief for the video composer.
4. Include camera, motion, lighting, subject action, and continuity constraints.
5. If a `voiceReference` node is connected, include the voice name/description as a spoken-voice direction unless it is a custom saved Flow voice that automation can attach through the picker.
6. Avoid asking for visible subtitles, captions, logos, or watermarks unless the user explicitly wants them.

## Model Notes

- Use `9:16` for short-form social/UGC unless the user says otherwise.
- `Veo 3.1 - Lite/Fast/Quality` currently uses the app-side default duration because Flow may not show a duration selector.
- `Omni Flash` can use explicit duration settings when Flow exposes them.
- Do not change workflow wiring from this skill; route ports through `veogenie-workflow-designer`.

## Before Run

Check the prompt for:

- The subject is identifiable and consistent.
- The first frame/end frame intent is clear if those ports are connected.
- Reference images are described as references, not frames, if connected to `video-reference-image`.
- Voice instructions do not contradict the selected `voiceReference`.
- The prompt does not request text overlays unless intentional.
