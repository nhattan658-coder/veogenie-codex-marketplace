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

## Product Video With Reference Images

Use this when the user provides several product/person/style images.

Edges:

- Main first frame: `imageReference:image -> videoGenerate:frame-start`
- Optional end frame: `imageReference:image -> videoGenerate:frame-end`
- Additional product/style/person references: `imageReference:image -> videoGenerate:video-reference-image`
- Prompt: `textPrompt:text -> videoGenerate:text`

Do not put all images into `frame-start`.

## Video With Voice

Nodes:

- `textPrompt` or `aiAssistant` for the spoken/video prompt.
- `voiceReference` for the selected voice.
- `videoGenerate`.

Edges:

- `textPrompt:text -> videoGenerate:text` or `aiAssistant:text -> videoGenerate:text`
- `voiceReference:voice -> videoGenerate:video-voice-reference`

If using the UI manually and the voice port is not visible, switch `Tao Video` to component/input view before connecting.

## Multi-Variant Results

Use `resultCount` on `imageGenerate` or `videoGenerate` instead of cloning identical branches when the user wants variants from the same prompt and inputs.

After running, verify count with `get_node_outputs` and node-specific `get_media_album`.
