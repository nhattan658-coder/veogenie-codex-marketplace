---
name: veogenie-video-director
description: Write and refine high-quality VeoGenie video prompts for Google Flow video generation. Use when Codex needs to direct scenes, camera motion, identity preservation, product or UGC ads, spoken lines, voice tone, frame/reference image usage, model-aware duration/aspect choices, or video prompt QA before running a videoGenerate node.
---

# VeoGenie Video Director

## Start

Use this skill when the user asks for video quality, video script, video prompt, UGC ad direction, voice tone, or scene/camera planning.

Read `references/video-prompt-rubric.md` before writing the final prompt.

If the task also requires creating or connecting workflow nodes, use `veogenie-workflow-designer` and its port contract.

If the task requires choosing or changing the `videoGenerate` model, use `veogenie-model-selector`.

If the task asks for a full viral script, hook structure, natural dialogue across multiple scenes, or several clips that form one short video, use `veogenie-viral-video-producer` before writing final per-scene prompts.

If the task needs identity, wardrobe, product, prop, location, or style continuity across scenes, use `veogenie-continuity-asset-planner` before final video prompts.

If the task should be grounded by a still image, fashion look, product hero, storyboard frame, or exact visual anchor, use `veogenie-image-to-video-input-planner` before final video prompts.

## Prompt Workflow

1. Identify the output format: product ad, UGC, cinematic, tutorial, demo, before/after, or story.
2. Identify source inputs: prompt text, start frame, end frame, reference images, voice reference.
3. Check whether important characters, wardrobe, props/products, or locations already have references; if not, plan those inputs before video.
4. If a generated still should control the clip, plan that image first and prune redundant video references.
5. Write one clear production brief for the video composer.
6. Include camera, motion, lighting, subject action, and continuity constraints.
7. If a `voiceReference` node is connected, include the voice name/description as a spoken-voice direction unless it is a custom saved Flow voice that automation can attach through the picker.
8. Avoid asking for visible subtitles, captions, logos, or watermarks unless the user explicitly wants them.

## Model Notes

- Use `9:16` for short-form social/UGC unless the user says otherwise.
- Prefer `omni-flash` for the most realistic video. Use Veo 3.1 models for normal video, fast drafts, or non-premium generation.
- `Veo 3.1 - Lite/Fast/Quality` currently uses the app-side default duration because Flow may not show a duration selector.
- `Omni Flash` can use explicit duration settings when Flow exposes them.
- Do not change workflow wiring from this skill; route ports through `veogenie-workflow-designer`.

## Before Run

Check the prompt for:

- The subject is identifiable and consistent.
- Recurring characters, wardrobe, props/products, and locations match the asset manifest or scene reference inputs.
- Redundant references have been omitted when the anchor image already contains the needed outfit, prop, product, style, or location.
- The first frame/end frame intent is clear if those ports are connected.
- Reference images are described as references, not frames, if connected to `video-reference-image`.
- Voice instructions do not contradict the selected `voiceReference`.
- The prompt does not request text overlays unless intentional.
