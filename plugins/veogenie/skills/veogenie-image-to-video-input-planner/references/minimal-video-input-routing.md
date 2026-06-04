# Minimal Video Input Routing

Use this reference to decide what to connect to `videoGenerate` and what to leave out.

## Input Budget

Start with the smallest set that can satisfy the scene:

```text
Required: one text prompt
Usually enough: one visual anchor image
Optional: identity/face reference, product reference, voice, exact end frame
Avoid: duplicate outfit/style/prop refs already visible in the anchor image
```

## Routing Matrix

| Need | Connect | Target handle | Omit when |
| --- | --- | --- | --- |
| Scene instructions/dialogue/motion | `textPrompt:text` or `aiAssistant:generatedText` | `text` | Never omit text. |
| Exact opening frame | generated or supplied image | `frame-start` | The image is only a loose reference or style guide. |
| Exact ending frame | generated or supplied image | `frame-end` | The user did not ask for an exact final frame. |
| Character identity/face guide | 1-3 useful face/character images | `video-reference-image` | The anchor image already shows the face clearly and identity is not strict. |
| Product identity | product image or generated product still | `video-reference-image` | The anchor image already contains the exact product clearly and no logo/package fidelity risk exists. |
| Outfit/fashion look | generated fashion still | `frame-start` or `video-reference-image` | Separate clothing refs repeat the same outfit already visible in the generated still. |
| Location/style/background | location/style image | `video-reference-image` | The location is generic, one-off, or already clear in the anchor image. |
| Voice/narration | `voiceReference:voice` | `video-voice-reference` | No spoken/narrated voice is requested. |

## Omit Rules

Omit an input when:

- It repeats information already encoded in the anchor image.
- It belongs to a different scene.
- It describes a different outfit, product variant, character version, or location than the current scene.
- It is a raw asset planning reference, not something the video model needs.
- It increases ambiguity, such as multiple clothing refs plus a generated final outfit still.

## Keep Rules

Keep an input when:

- It is the exact first or last frame requested by the user.
- It is the only reliable identity reference for a recurring character.
- It is the only reliable product/package reference and visual fidelity matters.
- It is a generated image that intentionally combines several details into one clean anchor.
- It is a shared voice node needed across scenes.

## Verification

Before running video, verify:

- Every connected upstream image node is `success`.
- The generated anchor image exists in VeoGenie app state.
- Each edge uses the intended handle.
- No extra image reference is connected only because it was available.
