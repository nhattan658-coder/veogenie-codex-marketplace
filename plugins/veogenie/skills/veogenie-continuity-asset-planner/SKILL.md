---
name: veogenie-continuity-asset-planner
description: Plan and create reusable continuity inputs before VeoGenie video generation. Use when Codex needs to detect missing characters, cast members, wardrobe, props, products, locations, backgrounds, style references, or shared voice/assets across a script, storyboard, viral video, ad, UGC sequence, or multi-scene workflow, then create image/reference nodes before videoGenerate clips.
---

# VeoGenie Continuity Asset Planner

Use this skill before building or running multi-scene videos when the final clip set needs consistent people, products, props, wardrobe, backgrounds, style, or voice.

## Pair With

- Use `veogenie-viral-video-producer` for hook, beat sheet, scene splitting, and natural dialogue.
- Use `veogenie-workflow-designer` for node/edge recipes and explicit handles.
- Use `veogenie-model-selector` for image model, video model, resolution, aspect ratio, and duration choices.
- Use `veogenie-image-to-video-input-planner` after the asset manifest is ready, so only necessary generated/supplied assets are connected to each video scene.
- Use `veogenie-video-director` for final per-scene prompts after the continuity inputs are planned.
- Use `veogenie-result-qa` after running pre-production assets or video clips.

## Process

1. Scan the brief, supplied images, script, and scene plan. Read `references/continuity-asset-manifest.md`.
2. Build an asset manifest with characters, wardrobe, props/products, locations/backgrounds, visual style, and voice. Mark each asset as `provided`, `missing`, `generated-upstream`, or `scene-only`.
3. Apply the continuity gate:
   - Every named or important character that appears in the script needs a reference image before video generation.
   - If the user supplied only one main character but the script introduces more important characters, create those missing character reference images first.
   - Recurring wardrobe, signature props, products, vehicles, rooms, storefronts, or backgrounds that appear in multiple scenes need a shared reference image or an explicit shared prompt block.
   - One-off simple props/backgrounds can stay in the scene prompt unless they are plot-critical or the user asks for exact continuity.
4. For each missing visual asset that should be reusable, read `references/preproduction-workflow-patterns.md` and create a pre-production branch before video clips: `textPrompt` -> `imageGenerate`. If a user image exists, route it through `imageReference`; never pass raw media or URLs through the recipe.
5. Choose image models with `veogenie-model-selector`: usually `gpt-image-2` for realistic character/storyboard continuity refs, or Nano Banana Pro/Nano Banana 2 at `2K`/`4K` for high-quality hero product/asset refs.
6. Use `veogenie-image-to-video-input-planner` to prune the per-scene video inputs. Connect finished asset refs to `video-reference-image` only when they add necessary identity/product/look/location information. Use `frame-start`/`frame-end` only when the asset is meant to be the exact first/last frame. Keep voice on `video-voice-reference`.
7. Run pre-production asset nodes first, in parallel when independent. Verify outputs before running dependent video nodes.
8. Keep every scene prompt consistent with the asset manifest. Do not rename characters, change outfits, or contradict shared asset descriptions unless the script intentionally calls for a change.

## Output Contract

When planning, include:

- `assetManifest`: reusable assets with type, continuity scope, provided/missing state, scene uses, and proposed node ids.
- `missingInputs`: critical assets that must be generated or supplied before video.
- `preProductionWorkflow`: nodes and explicit edges for generating missing asset refs.
- `sceneAssetRouting`: which asset refs feed each `videoGenerate` node and through which handle.
- `runOrder`: asset generation first, then video scenes, then QA/export.
- `continuityWarnings`: any script element that needs a reference but cannot be created with the current inputs/permissions.

## Quality Rules

- Do not create a multi-scene video workflow where an important recurring character, product, prop, outfit, or location appears in prompts but is missing from the manifest.
- Do not use `resultCount` as a substitute for different characters or scene-specific assets. Use separate asset nodes when the visual identity differs.
- Do not connect the same image to both `frame-start` and `video-reference-image` unless the user explicitly asks for both meanings and the app supports the intended routing.
- Do not claim final continuity is verified until the generated asset refs and final clips have been checked from VeoGenie app state.
- Do not claim one final stitched video unless the workflow includes a verified `videoMerge` node that has run successfully.
