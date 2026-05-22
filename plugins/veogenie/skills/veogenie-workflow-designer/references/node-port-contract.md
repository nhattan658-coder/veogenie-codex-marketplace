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

## Invalid Edges

Never create these edges:

- `voiceReference:voice -> videoGenerate:text`
- `voiceReference:voice -> videoGenerate:frame-start`
- `voiceReference:voice -> videoGenerate:frame-end`
- `voiceReference:voice -> videoGenerate:video-reference-image`
- `imageReference:image -> videoGenerate:text`
- `textPrompt:text -> videoGenerate:frame-start`
- `textPrompt:text -> videoGenerate:video-reference-image`

## Default Handle Trap

When an image source is connected to `videoGenerate` without an explicit target handle, app defaults may choose `frame-start`.

Therefore, for video workflows, always set one of:

- `frame-start`
- `frame-end`
- `video-reference-image`

based on the user intent.

## Preflight Checklist

Before calling `create_workflow_page` or `append_workflow_to_current_page`:

- Every edge has `sourceHandle`.
- Every edge has `targetHandle`.
- Voice edges target only `video-voice-reference`.
- Video reference image edges target `video-reference-image`, not `frame-start`, unless the image is explicitly the first frame.
- Start and end frames are assigned deliberately.
- Recipe does not include raw media payloads.
