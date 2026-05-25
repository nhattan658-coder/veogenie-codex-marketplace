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

## Photorealistic Quality Bar

For realistic product, person, lifestyle, or UGC videos, make the prompt concrete enough that the model has a single believable shot to execute:

- Use physical camera language: handheld phone, tripod, slow dolly, macro push-in, shallow depth of field, natural lens compression.
- Specify real-world light behavior: soft window light, diffused studio key, rim light, practical reflections, contact shadows, accurate skin or material highlights.
- Keep motion plausible: small human gestures, product turntable, liquid pour, steam, fabric movement, handheld micro-shake, no impossible morphing.
- Preserve source identity: same face, body proportions, product silhouette, color, label placement, material, and scale.
- Prefer one scene and one main action. Avoid asking for multiple unrelated locations, time jumps, or too many campaign ideas in one generation.
- Do not request visible text, captions, UI, subtitles, or logo changes unless the user explicitly asks for them.

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

## Photorealistic Video Template

Use this template when the user asks for realistic, premium, cinematic, or high-quality video:

```text
Photorealistic [aspect ratio] video, [duration/model expectation], [format such as premium product ad, natural UGC, lifestyle demo]. Keep [subject/product] exactly consistent with the reference: [identity, shape, color, label, material]. Scene: [specific real location or set], with [props/background] that support the product and do not compete. Action: [single clear beginning, middle, end]. Camera: [framing, lens feel, movement, stabilization]. Lighting: [realistic source, softness, reflections, shadows]. Motion details: [small believable subject/product/environment motion]. Voice, if any: [language, exact spoken line, tone, speaker]. Constraints: no extra text, no watermark, no logo changes, no face or product morphing, no distorted hands, no sudden scene jumps.
```

## Final QA

Before using the prompt:

- It has one clear visual idea.
- It names the spoken language if there is speech.
- It says what not to change.
- It avoids conflicting camera directions.
- It does not ask the model to create UI text unless intentional.
- It has a realistic camera, lighting, and motion plan instead of only quality adjectives.
- It preserves every required frame/reference/voice role without mixing `frame-start`, `frame-end`, `video-reference-image`, or `voiceReference`.
- It is short enough for the composer to keep the main instruction intact.
