---
name: veogenie-image-to-video-input-planner
description: Plan image-first VeoGenie video workflows with minimal, necessary inputs. Use when Codex needs to decide whether to create an upstream imageGenerate node before videoGenerate, choose the right video handles, route only essential face/character/product/fashion/look references, omit redundant wardrobe/prop/style inputs that would confuse the model, or build fashion/product/character videos from generated still images.
---

# VeoGenie Image To Video Input Planner

Use this skill when a video should be grounded by a generated or supplied image, and the agent must avoid over-connecting references that can confuse image/video models.

## Pair With

- Use `veogenie-workflow-designer` for explicit node/edge handles.
- Use `veogenie-model-selector` for choosing the upstream image model and downstream video model.
- Use `veogenie-continuity-asset-planner` when the script has multiple recurring people, products, props, wardrobe, or locations.
- Use `veogenie-video-director` after the input plan is decided, so the final prompt matches the selected inputs.
- Use `veogenie-result-qa` after running generated image anchors or video clips.

## Process

1. Read `references/minimal-video-input-routing.md`.
2. Identify the visual anchor for the video: fashion look, product hero, character pose, storyboard frame, location shot, or user-supplied image.
3. Decide whether to create an image before video:
   - Create an upstream `imageGenerate` when the video depends on a precise look, outfit, product staging, character pose, scene composition, or first frame.
   - Skip image generation only when the user already supplied a strong anchor image or the video is mostly text/voice-driven with no strict visual continuity.
4. Build the smallest useful input set for each `videoGenerate`:
   - Always include one direct text input.
   - Use one generated/supplied anchor image as `frame-start` if it should be the exact first frame.
   - Use `video-reference-image` for identity, face, product, style, or look references that should guide the clip but are not exact first/last frames.
   - Use `frame-end` only when the user asked for an exact final frame.
   - Use `video-voice-reference` only when voice/narration matters.
5. Read `references/image-first-patterns.md` for domain patterns such as fashion, product, character, and storyboard video.
6. Prune redundant inputs before writing the recipe. For every possible input, decide `connect` or `omit` with a short reason.
7. Run the upstream image nodes first. Verify generated image outputs from VeoGenie app state before running dependent video nodes.

## Output Contract

When planning, include:

- `imageFirstDecision`: whether to create image(s) before video and why.
- `anchorImages`: supplied or generated images that should drive each video.
- `minimalInputSet`: exactly which inputs feed each `videoGenerate`, with `sourceNodeId`, `sourceHandle`, `targetHandle`, and purpose.
- `omittedInputs`: references intentionally not connected, with the reason they would be redundant or confusing.
- `workflowPlan`: image-first nodes, video nodes, and explicit edges.
- `runOrder`: upstream image generation, verification, video generation, QA/export.

## Hard Rules

- Do not connect every available reference image to `videoGenerate`. More references can reduce control when they repeat the same information or compete with the anchor image.
- Do not connect a wardrobe/prop/style reference if the generated anchor image already clearly contains that wardrobe/prop/style and the video only needs to animate the anchor.
- Do not connect a reference to both `frame-start` and `video-reference-image` unless the user clearly asked for both meanings.
- Do not use `frame-start` for a generic reference image. Use it only when the image must be the opening frame.
- Do not use `resultCount` as a substitute for different anchors, outfits, products, or scenes. Create separate image/video branches when the visual target differs.
- Do not run a downstream `videoGenerate` until every connected upstream `imageGenerate` dependency is `success` and has a generated asset.

## Fashion Default

For fashion video, default to image-first:

1. Generate the fashion still/look first: model, outfit, pose, styling, lighting, and background.
2. Feed the generated fashion image to the video node as `frame-start` when the clip should begin from that still, or `video-reference-image` when it is only a look reference.
3. Add multi-angle face/identity images only if character identity matters and those images add information not already present in the fashion still.
4. Omit separate clothing/wardrobe reference images when the generated fashion still already contains the final outfit clearly. Add them only when product fidelity is at risk or the still has not been generated yet.
