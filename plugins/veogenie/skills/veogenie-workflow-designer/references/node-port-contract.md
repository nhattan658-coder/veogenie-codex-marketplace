# VeoGenie Node Port Contract

Use this file before creating or editing workflow recipes.

## Supported Recipe Node Types

MCP workflow authoring supports:

- `group`
- `textPrompt`
- `imageReference`
- `voiceReference`
- `imageGenerate`
- `videoGenerate`
- `videoMerge`
- `aiAssistant`

Do not use `collection` in MCP recipes unless the MCP contract explicitly adds support later.

## Source Handles

Use these source handles:

| Source node type | Source handle | Meaning |
| --- | --- | --- |
| `textPrompt` | `text` | Prompt text. |
| `aiAssistant` | `text` | Current generated text output. |
| `aiAssistant` | `assistant-text:N` | Specific assistant batch text, zero-based index. Use only when selecting a specific batch item. |
| `imageReference` | `image` | Uploaded/reference image. |
| `imageGenerate` | `image` | Current generated image output. |
| `videoGenerate` | `video` | Current generated video output. |
| `videoMerge` | `video` | Current merged video output. |
| `voiceReference` | `voice` | Flow voice reference or voice prompt hint. |

## Target Handles

### `imageGenerate`

Common target handles:

- `text`: prompt text.
- `image`: reference image or upstream generated image.
- `video`: video input if the UI/workflow supports video-to-image context.

Use text and image for normal image generation workflows.

### `aiAssistant`

Common target handles:

- `text`: instruction or source text.
- `image`: image context.
- `video`: video context.

### `videoGenerate`

Use these target handles exactly:

| Target handle | Meaning | Multiplicity |
| --- | --- | --- |
| `text` | Main video prompt/script. | Usually one effective text prompt. |
| `frame-start` | Frame 1 / start image / `Bat dau`. | Single slot. |
| `frame-end` | Frame 2 / end image / `Ket thuc`. | Single slot. |
| `video-reference-image` | Component/reference images for style, person, product, or scene. | Multiple allowed. |
| `video-voice-reference` | Voice reference input for `voiceReference`. | Single effective voice. |

Do not confuse `frame-start`, `frame-end`, and `video-reference-image`.

### `videoMerge`

Use this target handle exactly:

| Target handle | Meaning | Multiplicity |
| --- | --- | --- |
| `video` | Source video clip to merge. | Multiple allowed; merge order follows connected source order in the workflow. |

Valid sources are video outputs only:

- `videoGenerate:video -> videoMerge:video`
- `videoMerge:video -> videoMerge:video`

Do not connect text, image, or voice handles into `videoMerge`.

## Video Image Routing By User Intent

Choose video image ports from the user's wording, not from convenience.

### Video From Frames Or Keyframes

Use this when the user says the video should be made from a frame, first frame, last frame, start/end frame, storyboard frame, or exact keyframe.

- One image that should open the video: `imageReference:image -> videoGenerate:frame-start` or `imageGenerate:image -> videoGenerate:frame-start`.
- Two images that define the start and ending: first image -> `frame-start`, second image -> `frame-end`.
- Do not also connect those frame images to `video-reference-image`.
- Do not add `video-voice-reference` unless the user asked for narration, voice, speaker, or synchronized voice.

### Video With Synchronized Voice Or Narration

Use this when the user asks for voice sync, narration, spoken line, speaker voice, consistent voice, or one voice shared across videos.

- Connect the voice node as `voiceReference:voice -> videoGenerate:video-voice-reference`.
- Connect image inputs as `imageReference:image -> videoGenerate:video-reference-image` or `imageGenerate:image -> videoGenerate:video-reference-image`.
- Do not place all images into `frame-start`/`frame-end` just because they are images.
- Use `frame-start` or `frame-end` in a voice workflow only when the user explicitly says an image must be the exact first or last frame.

If the request includes both exact frames and voice, use both contracts: exact frame images go to `frame-start`/`frame-end`, other visual references go to `video-reference-image`, and the voice goes to `video-voice-reference`.

## Common Valid Edges

```json
{
  "source": "prompt-1",
  "target": "image-1",
  "sourceHandle": "text",
  "targetHandle": "text"
}
```

```json
{
  "source": "reference-1",
  "target": "image-1",
  "sourceHandle": "image",
  "targetHandle": "image"
}
```

```json
{
  "source": "image-1",
  "target": "video-1",
  "sourceHandle": "image",
  "targetHandle": "frame-start"
}
```

```json
{
  "source": "product-reference",
  "target": "video-1",
  "sourceHandle": "image",
  "targetHandle": "video-reference-image"
}
```

```json
{
  "source": "voice-1",
  "target": "video-1",
  "sourceHandle": "voice",
  "targetHandle": "video-voice-reference"
}
```

```json
{
  "source": "video-scene-01",
  "target": "merge-final",
  "sourceHandle": "video",
  "targetHandle": "video"
}
```

## Invalid Edges

Never create these edges:

- `voiceReference:voice -> videoGenerate:text`
- `voiceReference:voice -> videoGenerate:frame-start`
- `voiceReference:voice -> videoGenerate:frame-end`
- `voiceReference:voice -> videoGenerate:video-reference-image`
- `imageReference:image -> videoGenerate:text`
- `textPrompt:text -> videoGenerate:frame-start`
- `textPrompt:text -> videoGenerate:video-reference-image`
- `textPrompt:text -> videoMerge:video`
- `imageReference:image -> videoMerge:video`
- `imageGenerate:image -> videoMerge:video`
- `voiceReference:voice -> videoMerge:video`

## Default Handle Trap

When an image source is connected to `videoGenerate` without an explicit target handle, app defaults may choose `frame-start`.

Therefore, for video workflows, always set one of:

- `frame-start`
- `frame-end`
- `video-reference-image`

based on the user intent.

For `videoMerge`, always set `targetHandle` to `video`; never use a videoGenerate frame/reference handle on the merge node.

## Preflight Checklist

Before calling `create_workflow_page` or `append_workflow_to_current_page`:

- Every edge has `sourceHandle`.
- Every edge has `targetHandle`.
- Voice edges target only `video-voice-reference`.
- A "video from frame/keyframe" request uses `frame-start`/`frame-end`, not `video-reference-image`, unless the user separately asks for reference images.
- A "voice sync/narration" request routes image inputs to `video-reference-image` plus `voiceReference:voice -> video-voice-reference`, unless the user explicitly asks for exact first/last frames.
- Video reference image edges target `video-reference-image`, not `frame-start`, unless the image is explicitly the first frame.
- Start and end frames are assigned deliberately.
- Merge edges target only `videoMerge:video` and come from upstream video outputs.
- A merge workflow has at least two source video clips before the `videoMerge` node is run.
- Recipe does not include raw media payloads.
