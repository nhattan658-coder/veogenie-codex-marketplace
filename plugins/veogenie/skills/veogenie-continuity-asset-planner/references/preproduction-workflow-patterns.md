# Pre-Production Workflow Patterns

Use these patterns when the asset manifest says an input must exist before video generation.

## Character Reference Branch

Nodes:

- `textPrompt`: character sheet prompt.
- Optional `imageReference`: user-supplied face/style/product context.
- `imageGenerate`: reusable character reference output.

Edges:

```text
textPrompt:text -> imageGenerate:text
imageReference:image -> imageGenerate:image
imageGenerate:generatedAsset -> videoGenerate:video-reference-image
```

Prompt shape:

```text
Create a clean realistic reference image for [character name].
Show face, hair, age range, body type, outfit, and distinctive details.
Neutral background, no text, no watermark. This image will be reused as a video character reference.
```

Use `gpt-image-2` for realistic character refs/storyboards unless the user asks for high-resolution final still assets.

## Prop Product Or Location Reference Branch

Nodes:

- `textPrompt`: asset reference prompt.
- Optional `imageReference`: supplied product/prop/location reference.
- `imageGenerate`: reusable asset reference output.

Edges:

```text
textPrompt:text -> imageGenerate:text
imageReference:image -> imageGenerate:image
imageGenerate:generatedAsset -> videoGenerate:video-reference-image
```

Use Nano Banana Pro or Nano Banana 2 at `2K`/`4K` for high-quality product, wardrobe, hero prop, or location refs when detail matters.

## Scene Video Branch With Shared Assets

Nodes:

- `textPrompt`: scene-specific video prompt.
- `videoGenerate`: one clip for one scene.
- Shared upstream character/prop/location image outputs.
- Optional shared `voiceReference`.

Edges:

```text
textPrompt:text -> videoGenerate:text
imageGenerate:generatedAsset -> videoGenerate:video-reference-image
imageReference:image -> videoGenerate:video-reference-image
voiceReference:voice -> videoGenerate:video-voice-reference
```

Use `frame-start` only for a generated/storyboard image that must be the exact first frame:

```text
imageGenerate:generatedAsset -> videoGenerate:frame-start
```

Do not also route that same exact first frame to `video-reference-image` unless the user clearly wants both meanings.

## Run Order

1. Create/attach all required `imageReference` nodes for user-provided inputs.
2. Run all independent pre-production `imageGenerate` nodes for missing characters, props, wardrobe, products, and locations.
3. Verify generated asset refs from VeoGenie app state with `get_node_outputs` and node-specific `get_media_album`.
4. Run dependent `videoGenerate` scene nodes only after their required assets are `success`.
5. Export final clips in scene order after QA.

## Naming

Use stable ids:

```text
prompt-char-linh
image-char-linh
prompt-char-minh
image-char-minh
prompt-prop-package
image-prop-package
prompt-loc-cafe
image-loc-cafe
prompt-scene-01-hook
video-scene-01-hook
```
