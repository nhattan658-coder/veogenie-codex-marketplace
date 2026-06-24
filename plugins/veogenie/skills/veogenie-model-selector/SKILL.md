---
name: veogenie-model-selector
description: Choose suitable VeoGenie models and node settings for imageGenerate and videoGenerate nodes. Use when Codex needs to select, review, or update model/provider/resolution/duration/geminiThinkingLevel fields for realistic images, storyboard frames, high-quality image renders, photorealistic videos, Gemini web videos, normal videos, or workflow recipes created through the VeoGenie MCP plugin.
---

# VeoGenie Model Selector

Use this skill before creating or updating `imageGenerate` or `videoGenerate` node settings.

## Model Ids

Image models:

- `gpt-image-2`: GPT Image 2, provider `openai`.
- `gemini-3-pro-image-preview`: Nano Banana Pro, provider `google`.
- `gemini-2.5-flash-image`: Nano Banana 2, provider `google`.

Video models:

- `omni-flash`: Omni Flash, provider `google`.
- `veo-3.1-lite`: Veo 3.1 - Lite, provider `google`.
- `veo-3.1-fast`: Veo 3.1 - Fast, provider `google`.
- `veo-3.1-quality`: Veo 3.1 - Quality, provider `google`.
- `gemini-3.1-flash-lite-video`: Gemini 3.1 Flash-Lite on `gemini.google.com`, provider `google`.
- `gemini-3.5-flash-video`: Gemini 3.5 Flash on `gemini.google.com`, provider `google`.
- `gemini-3.1-pro-video`: Gemini 3.1 Pro on `gemini.google.com`, provider `google`.

## Image Selection

- For realistic people, natural lifestyle images, photoreal scenes, storyboard/keyframe drafts, character continuity, or shots that must feel like real camera frames, prefer `gpt-image-2`.
- For high-quality final images, premium product renders, sharp commercial visuals, or requests that explicitly ask for `2K`, `4K`, high detail, high resolution, or best image quality, prefer `gemini-3-pro-image-preview` first.
- Use `gemini-2.5-flash-image` as the second Google image choice when Nano Banana Pro is unavailable, the user wants faster iteration, or the prompt says Nano Banana 2.
- If the user explicitly names a model, keep that model unless it conflicts with the node type.
- If the brief asks for both realistic storyboard frames and maximum final image quality, choose by primary intent: storyboard/real camera feel -> `gpt-image-2`; final high-resolution render -> `gemini-3-pro-image-preview`.

Image node fields:

```json
{
  "type": "imageGenerate",
  "provider": "google or openai",
  "model": "model-id",
  "aspectRatio": "1:1, 4:5, 3:4, 2:3, 9:16, or 16:9",
  "width": 2048,
  "height": 2048
}
```

Resolution defaults:

- Normal draft: `1K`.
- Better quality or multiple variants: `2K`.
- Final premium image or explicit high quality: `4K` when the selected model supports it.
- For Google image models, square `2K` is `2048x2048` and square `4K` is `4096x4096`.
- For `gpt-image-2`, use the app's supported sizes; square `2K` is `2048x2048` and square `4K` is `2160x2160`.
- Preserve the user's requested aspect ratio. If none is given, use `9:16` for stories/short-form social, `1:1` for product/feed images, and `16:9` for wide storyboard or presentation frames.

## Video Selection

- For the most realistic video, cinematic human motion, believable product/lifestyle motion, strong reference-image consistency, or any request that says "most realistic", "realistic nhat", "chan thuc nhat", "cinematic", or "premium video", prefer `omni-flash`.
- For normal video, simple image-to-video, fast drafts, or low-risk internal previews, use `veo-3.1-lite`.
- Use `veo-3.1-fast` when the user prioritizes speed.
- Use `veo-3.1-quality` when the user wants better Veo output but did not ask for the most realistic/Omni result.
- Use `gemini-3.1-flash-lite-video`, `gemini-3.5-flash-video`, or `gemini-3.1-pro-video` only when the user explicitly wants the Gemini web video flow. These models open `https://gemini.google.com/`; do not treat them as Google Flow/labs models.
- For Gemini web video, choose `gemini-3.1-flash-lite-video` for fast/light drafts, `gemini-3.5-flash-video` for balanced Gemini web video, and `gemini-3.1-pro-video` for complex prompts, many constraints, or best Gemini web reasoning.
- Keep `duration` at `8` for Veo 3.1 models unless the user has a clear reason otherwise, because Flow may not expose a duration selector for those models.
- For `omni-flash`, choose `4`, `6`, `8`, or `10` seconds based on the requested pacing; default to `8` for normal shots and `10` for richer action when the user wants maximum realism.

Gemini web thinking level:

- Use `geminiThinkingLevel: "standard"` when the user wants a simple/fast Gemini web video or the prompt has few constraints.
- Use `geminiThinkingLevel: "extended"` for complex prompts, product fidelity, multi-subject scenes, exact motion/camera requirements, or when the user wants the strongest Gemini web result.
- Default to `extended` for Gemini web video if the user does not specify speed or thinking level.
- Do not set `geminiThinkingLevel` on `veo-3.1-lite`, `veo-3.1-fast`, `veo-3.1-quality`, or `omni-flash`; those remain Google Flow/labs models.

Video node fields:

```json
{
  "type": "videoGenerate",
  "provider": "google",
  "model": "model-id",
  "aspectRatio": "16:9 or 9:16",
  "duration": 8,
  "geminiThinkingLevel": "standard or extended, only for Gemini web video models"
}
```

## Workflow Rules

- Do not put an image model on `videoGenerate` or a video model on `imageGenerate`.
- When designing or editing workflow recipes, pair this skill with `veogenie-workflow-designer` for explicit edge handles.
- When writing video prompts, pair this skill with `veogenie-video-director`; model choice does not replace a concrete camera/action prompt.
- When editing existing nodes, use `update_workflow_nodes` only after `canvas_write` permission is enabled and `confirmModifyCurrentPage=true` is present. For Gemini web video nodes, update `model` and `geminiThinkingLevel` together when the user changes Gemini model intent.
- Do not run nodes just to test a model choice unless the user explicitly asks to generate and `actions` permission is enabled.
