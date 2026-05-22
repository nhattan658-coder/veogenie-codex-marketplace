---
name: veogenie-product-ad
description: Create high-quality VeoGenie product advertising workflows, prompts, and execution plans. Use when Codex needs to make product images, product videos, launch ads, social ads, ecommerce hero shots, campaign variants, or an end-to-end product ad job through the VeoGenie MCP plugin.
---

# VeoGenie Product Ad

## Scope

Use this skill for product-focused creative work. Pair it with the core `veogenie` skill for MCP safety and with `veogenie-workflow-designer` when building or reviewing node structure.

## Default Process

1. Extract the product, audience, campaign goal, format, aspect ratio, and desired output count from the user's request.
2. If a local product image path is provided, plan to use `imageReference` plus `attach_local_media_to_node` after the workflow page exists and media import permission is granted.
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

## References

Read `references/product-ad-rubric.md` when drafting product prompts, choosing a shot style, or checking creative quality.
