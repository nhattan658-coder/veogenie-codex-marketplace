# VeoGenie Workflow Patterns

Use these as safe starting points for MCP workflow recipes. Keep all handles explicit.

## Product Key Visual

Nodes:

- `imageReference`: product image, empty at recipe time.
- `textPrompt`: image direction.
- `imageGenerate`: key visual output.

Edges:

- `textPrompt:text -> imageGenerate:text`
- `imageReference:image -> imageGenerate:image`

Use this when the user asks for product photos, campaign key visuals, catalog images, or ad stills.

## AI Assistant Prompt Writer

Use this when the user wants AI to write or improve prompts before image/video generation.

Nodes:

- `textPrompt`: assistant instruction plus original brief.
- Optional `imageReference`: product/person/style context for the assistant.
- `aiAssistant`: writes final image prompt, video prompt, script, or prompt variants.
- Downstream `imageGenerate` or `videoGenerate`.

Edges:

- `textPrompt:text -> aiAssistant:text`
- Optional context: `imageReference:image -> aiAssistant:image`
- Image prompt: `aiAssistant:text -> imageGenerate:text`
- Video prompt/script: `aiAssistant:text -> videoGenerate:text`

If the assistant returns several batch texts and the workflow should use one specific variant, connect `aiAssistant:assistant-text:N` to the downstream node. Otherwise use `aiAssistant:text` for the current selected assistant output.

Do not connect assistant text to `frame-start`, `frame-end`, `video-reference-image`, or `video-voice-reference`.

## Product Video From Generated Image

Nodes:

- Product key visual pattern.
- `aiAssistant`: writes video script or prompt.
- `videoGenerate`: creates final video.

Edges:

- `imageGenerate:image -> videoGenerate:frame-start`
- `aiAssistant:text -> videoGenerate:text`

Only connect the generated image to `video-reference-image` if the user wants it as a reference/component, not as the first frame.

## Fashion Video From Generated Look

Use `veogenie-image-to-video-input-planner` for fashion videos. Prefer creating the final fashion still/look before video.

Nodes:

- Optional `imageReference`: face/identity references or garment/product refs used only for upstream image creation.
- `textPrompt`: fashion still prompt.
- `imageGenerate`: creates the final fashion look/still.
- `textPrompt`: video motion/camera prompt.
- `videoGenerate`: creates the fashion video.

Edges:

- `textPrompt:text -> imageGenerate:text`
- Optional creation refs: `imageReference:image -> imageGenerate:image`
- Generated anchor: `imageGenerate:image -> videoGenerate:frame-start`
- Video prompt: `textPrompt:text -> videoGenerate:text`

Optional video refs:

- `imageReference:image -> videoGenerate:video-reference-image` only for face/identity refs or product refs that add necessary information not already clear in the generated fashion still.

Do not connect separate clothing/wardrobe references to `videoGenerate` when the generated fashion still already shows the final outfit clearly. This avoids making the video model mix the final look with redundant or competing garment refs.

## Product Video With Reference Images

Use this when the user provides several product/person/style images.

Edges:

- Main first frame: `imageReference:image -> videoGenerate:frame-start`
- Optional end frame: `imageReference:image -> videoGenerate:frame-end`
- Additional product/style/person references: `imageReference:image -> videoGenerate:video-reference-image`
- Prompt: `textPrompt:text -> videoGenerate:text`

Do not put all images into `frame-start`.

## Video From Frames Or Keyframes

Use this when the user asks for a video from one or two specific frames, keyframes, start/end frames, or a storyboard frame.

Edges:

- Prompt: `textPrompt:text -> videoGenerate:text`
- One exact opening frame: `imageReference:image -> videoGenerate:frame-start` or `imageGenerate:image -> videoGenerate:frame-start`
- Optional exact ending frame: `imageReference:image -> videoGenerate:frame-end` or `imageGenerate:image -> videoGenerate:frame-end`

Do not connect the same frame image to `video-reference-image`. Do not connect a voice node unless the user asked for voice or narration.

## Video With Voice

Nodes:

- `textPrompt` or `aiAssistant` for the spoken/video prompt.
- Optional `imageReference` or upstream `imageGenerate` outputs as visual references.
- `voiceReference` for the selected voice.
- `videoGenerate`.

Edges:

- `textPrompt:text -> videoGenerate:text` or `aiAssistant:text -> videoGenerate:text`
- Image inputs for voice-synced/narrated videos: `imageReference:image -> videoGenerate:video-reference-image` or `imageGenerate:image -> videoGenerate:video-reference-image`
- `voiceReference:voice -> videoGenerate:video-voice-reference`

When the user asks for synchronized voice or narration, route all image inputs to `video-reference-image` by default. Use `frame-start` or `frame-end` only if the user explicitly asks for exact first/last frames.

If using the UI manually and the voice port is not visible, switch `Tao Video` to component/input view before connecting.

## Multi-Variant Results

Use `resultCount` on `imageGenerate` or `videoGenerate` instead of cloning identical branches when the user wants variants from the same prompt and inputs.

After running, verify count with `get_node_outputs` and node-specific `get_media_album`.

## Viral Multi-Scene Short

Use `veogenie-viral-video-producer` for hook-driven scripts, natural dialogue, scene splitting, and ordered clip export. Do not model separate story beats as `resultCount`; create separate `textPrompt` + `videoGenerate` pairs for each scene.

Before creating scene video nodes, use `veogenie-continuity-asset-planner` when the script has missing or recurring characters, props/products, wardrobe, locations, or style references. Create the required pre-production `textPrompt` + `imageGenerate` asset branches first, then route finished asset images to each scene through `video-reference-image`.

For any scene grounded by a generated still, use `veogenie-image-to-video-input-planner` to decide whether that still belongs on `frame-start` or `video-reference-image`, and to omit redundant refs that would confuse the video model.
