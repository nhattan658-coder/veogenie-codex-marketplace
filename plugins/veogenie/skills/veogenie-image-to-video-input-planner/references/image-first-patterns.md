# Image-First Video Patterns

Use these patterns when a video should be grounded by a still image before motion generation.

## Fashion Video

Use image-first by default.

Pre-production:

```text
textPrompt:text -> imageGenerate:text
optional face/image refs -> imageGenerate:image
```

Video:

```text
imageGenerate:generatedAsset -> videoGenerate:frame-start
textPrompt:text -> videoGenerate:text
```

Optional:

```text
imageReference:image -> videoGenerate:video-reference-image
voiceReference:voice -> videoGenerate:video-voice-reference
```

Connect face references only when identity must stay consistent. Omit separate wardrobe references when the generated fashion still already shows the full outfit clearly. This prevents the video model from mixing the final look with older garment references.

## Product Video

Use image-first when the product staging, lighting, angle, or composition must be controlled.

```text
product imageReference:image -> imageGenerate:image
textPrompt:text -> imageGenerate:text
imageGenerate:generatedAsset -> videoGenerate:frame-start
textPrompt:text -> videoGenerate:text
```

Add the original product reference to `video-reference-image` only when product identity or packaging fidelity is at risk. If the generated hero image is already accurate and clear, omit the original product reference from the video node.

## Character Or UGC Video

Use image-first when a character's pose, outfit, or scene setup needs a clean anchor.

```text
character refs -> imageGenerate:image
textPrompt:text -> imageGenerate:text
imageGenerate:generatedAsset -> videoGenerate:frame-start
textPrompt:text -> videoGenerate:text
voiceReference:voice -> videoGenerate:video-voice-reference
```

Add multi-angle face references to `video-reference-image` only when they improve identity consistency. Do not add every character asset if only one person appears in the scene.

## Storyboard Or Exact Keyframe Video

Use image-first when the user asks for a storyboard, exact first frame, or keyframe-based video.

```text
textPrompt:text -> imageGenerate:text
imageGenerate:generatedAsset -> videoGenerate:frame-start
textPrompt:text -> videoGenerate:text
```

Use `frame-end` only for a second generated/provided image that must be the exact final frame.

## When Not To Generate Image First

Skip image-first when:

- The user already supplied a strong exact first frame.
- The scene is simple and prompt-driven, with no strict identity/product/outfit composition requirement.
- The user wants quick drafts and accepts visual variation.
- The required asset already exists as a verified generated image in VeoGenie app state.
