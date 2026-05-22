# VeoGenie Video Prompt Rubric

Use this rubric for `videoGenerate` prompts.

## Required Prompt Blocks

Include these ideas in natural prose, not as rigid headings unless helpful:

- Format: platform, aspect ratio, style, duration expectation.
- Subject: who or what appears, exact identity/product continuity.
- Scene: location, time of day, background, props.
- Action: what happens from start to finish.
- Camera: framing, lens feel, motion, camera stability.
- Lighting: quality, direction, realism.
- Motion: subject motion, object motion, environmental motion.
- Voice/spoken line: spoken language, line, tone, pacing, speaker.
- Constraints: no unwanted text, logo, watermark, identity change, morphing, or distorted hands/faces.

## Identity And Product Continuity

When using a person or product reference:

- Say the subject must keep the same face/product shape/color/material.
- Avoid broad phrases like "make it beautiful" without concrete continuity.
- If the user wants a stylized result, still preserve core identity/product details.

## Frame Inputs

When `frame-start` is connected:

- Treat it as the visual opening state.
- Describe the first shot as continuing naturally from that image.

When `frame-end` is connected:

- Treat it as the final target state.
- Describe the transition from start to end without sudden scene jumps.

When `video-reference-image` is connected:

- Treat images as references/components for identity, product, scene, or style.
- Do not describe them as the first frame unless they are also connected to `frame-start`.

## Voice Inputs

When `voiceReference` is connected:

- Include the voice name and tone if it is a preset voice.
- Include the spoken line explicitly.
- Keep the voice direction consistent with the visual style.
- Use one primary speaker unless the workflow has separate branches.

Example:

```text
Vietnamese spoken line in a soft, clear female voice matching the selected voice reference: "Chao buoi sang, hom nay minh chon mot bo that de thuong de bat dau ngay moi."
```

## Social UGC Pattern

Use this structure for phone vlog or social ad:

```text
Vertical 9:16 social video, natural phone vlog style. [Subject] keeps the same identity/product details from the reference. Scene: [specific setting]. Action: [beginning, middle, end]. Camera: handheld smartphone, close-medium framing, slight natural motion. Lighting: realistic, soft, no beauty distortion. Spoken line: [language and line]. Constraints: no text overlay, no logo, no watermark, no face morphing, no product shape changes.
```

## Product Ad Pattern

Use this structure for polished product ads:

```text
Premium product commercial, [aspect ratio]. Product must keep the exact shape, label/color/material from the reference. Scene: [surface/background/lighting]. Action: [product reveal/use/benefit]. Camera: [macro/slow push/parallax]. Lighting: [studio/natural]. Motion: [steam/splash/hand movement]. Constraints: no extra text, no fake logo changes, no warped packaging, no watermark.
```

## Final QA

Before using the prompt:

- It has one clear visual idea.
- It names the spoken language if there is speech.
- It says what not to change.
- It avoids conflicting camera directions.
- It does not ask the model to create UI text unless intentional.
