---
name: veogenie-product-ad
description: Create high-quality VeoGenie product advertising workflows, prompts, and execution plans. Use when Codex needs to make product images, product videos, launch ads, social ads, ecommerce hero shots, campaign variants, use aiAssistant/Tro Ly AI as a prompt writer, or run an end-to-end product ad job through the VeoGenie MCP plugin.
---

# VeoGenie Product Ad

## Scope

Use this skill for product-focused creative work. Pair it with the core `veogenie` skill for MCP safety and with `veogenie-workflow-designer` when building or reviewing node structure.

## Default Process

1. Extract the product, audience, campaign goal, format, aspect ratio, and desired output count from the user's request.
2. If a local product image path is provided, plan to use `imageReference` plus `attach_local_media_to_node` after the workflow page exists and media import permission is granted. If the product image came from chat, stage it as a local workspace file first and use `attach_chat_image_to_node`.
3. Prefer `plan_product_ad_job` for end-to-end planning and `build_product_ad_workflow_recipe` for recipe-only planning.
4. Create or append a workflow only after the user asks for that action and canvas-write permission is available.
5. Run image/video nodes only after the user asks to generate and action permission is available.
6. Verify results with node-specific `get_node_outputs` and `get_media_album`; export only verified media ids.

## Brief Minimum

If the request is underspecified, make conservative defaults:

- Goal: premium product ad.
- Audience: likely buyer for the product category.
- Aspect ratio: `9:16` for social video or story ads, `1:1` for marketplace/social feed images, `16:9` for wide presentation.
- Result count: `3` image variants for exploration, `1` final video unless the user asks for more.
- Style: clean commercial product photography with controlled lighting.

Ask a follow-up only when the missing detail blocks execution, such as no product image/path for a product-image job that requires one.

## Prompt Standards

Use prompts that specify:

- Product fidelity: keep packaging, labels, logo placement, proportions, and distinctive colors unchanged.
- Composition: product position, camera angle, framing, safe negative space, and crop behavior.
- Lighting: source, contrast, reflections, material highlights, and shadow softness.
- Environment: surface, background, props, and visual context that supports the product category.
- Campaign intent: premium, fresh, energetic, technical, luxury, natural, clinical, playful, or conversion-focused.
- Output constraints: no extra text unless requested, no invented logos, no distorted packaging, no extra products.

## Workflow Choices

- For image-only ads, use `imageReference` + `textPrompt` + `imageGenerate`.
- For image and video, generate a strong hero frame first, then feed it into `videoGenerate`.
- Use `aiAssistant` when the brief needs script, shot list, caption copy, or multiple prompt variants.
- Avoid `characterReference` / `Nhan Vat` while it is locked.

## AI Assistant Prompt Writer

Use `aiAssistant` / `Tro Ly AI` as a prompt writer when the user wants the agent to improve a rough brief, create prompt variants, write a video script, or turn product/image context into a polished image/video prompt.

Do not add an `aiAssistant` node when the user already provided a final prompt and no rewrite, variants, script, or interpretation is needed; a direct `textPrompt` is simpler.

Use this assistant instruction pattern:

```text
Write [one / N] production-ready VeoGenie [image/video] prompt(s) for this product ad brief.
Preserve exact product identity from any attached reference image: packaging, logo placement, color, shape, label, material, and scale.
Use a photorealistic commercial style with concrete camera, lighting, composition, material, and motion details.
For video, include one clear beginning/middle/end action, camera movement, realistic motion, optional spoken line, and constraints.
Return only the final prompt text or numbered prompt variants. Do not include analysis, markdown headings, or unrelated copy.
Constraints: no extra text overlays unless requested, no fake logos, no duplicate products, no watermark, no warped packaging.
```

Wire the result through the workflow designer contract:

- `textPrompt:text -> aiAssistant:text` for the brief or assistant instruction.
- `imageReference:image -> aiAssistant:image` when the assistant should read product/reference context.
- `aiAssistant:text -> imageGenerate:text` for generated image prompts.
- `aiAssistant:text -> videoGenerate:text` for generated video prompts/scripts.
- Use `aiAssistant:assistant-text:N` only when selecting one specific batch variant.

For product video wiring, follow the workflow designer intent contract:

- If the user asks for a product video from an exact frame/keyframe, connect that image to `videoGenerate:frame-start` and an optional ending image to `videoGenerate:frame-end`; do not duplicate those frame images into `video-reference-image`.
- If the user asks for synchronized voice, narration, or shared speaker voice, connect product/style/person images to `videoGenerate:video-reference-image` by default and connect `voiceReference:voice -> videoGenerate:video-voice-reference`.
- Use `frame-start`/`frame-end` in a voice workflow only when the user explicitly asks for exact first/last frames.

After running `aiAssistant`, verify its text output with `get_node_outputs` before running downstream image/video nodes. If the assistant output is vague, asks for visible text unintentionally, or drops product identity constraints, update the assistant instruction and rerun only after no command is queued/running.

## References

Read `references/product-ad-rubric.md` when drafting product prompts, choosing a shot style, or checking creative quality.
