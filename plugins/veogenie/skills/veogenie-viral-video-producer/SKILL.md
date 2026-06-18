---
name: veogenie-viral-video-producer
description: Create viral-style short video scripts and convert them into VeoGenie multi-scene workflows. Use when Codex needs to write hooks, viral beat structures, natural character dialogue, voice-aware video prompts, or multiple videoGenerate clips that form one story, ad, UGC, Shorts, Reels, or TikTok-style video with ordered exports.
---

# VeoGenie Viral Video Producer

Use this skill when the user wants a complete short-form video concept, script, or multi-clip workflow rather than one isolated video prompt.

## Pair With

- Use `veogenie` for MCP safety, permissions, run/poll, and result handoff.
- Use `veogenie-workflow-designer` for node/edge recipes and explicit handles.
- Use `veogenie-model-selector` for image/video model, duration, and resolution choices.
- Use `veogenie-continuity-asset-planner` before video nodes when a script uses multiple characters, recurring props/products, wardrobe, locations, style refs, or shared voice.
- Use `veogenie-image-to-video-input-planner` when a scene should start from a generated still/storyboard/fashion/product image or when video inputs need pruning.
- Use `veogenie-video-director` for final per-scene video prompt polish.
- Use `veogenie-result-qa` after running clips.

## Process

1. Extract the brief: platform, audience, topic/product, goal, duration, language, speaker/persona, available references, voice, and whether the user wants final files.
2. Read `references/viral-script-structures.md` and create a beat sheet with a hook, setup, escalation/proof, payoff, and CTA or loop ending.
3. Split the beat sheet into scene clips. Default to `9:16`, `20-45s`, and `3-6` clips unless the user gives another target.
4. Use `veogenie-continuity-asset-planner` to create an asset manifest before video nodes. If the script introduces characters, props, wardrobe, or locations not supplied by the user, plan or create those reference images first.
5. Use `veogenie-image-to-video-input-planner` for scenes that need generated still anchors, storyboard frames, fashion looks, or product hero frames before video.
6. Read `references/natural-dialogue-rubric.md` and write exact spoken lines for each scene. Keep the lines short, human, and speakable.
7. Turn each scene into one `textPrompt` plus one `videoGenerate` node. Each scene prompt must include scene role, duration, visual action, camera, continuity constraints from the asset manifest, exact dialogue, and transition intent.
8. Read `references/multi-scene-workflow-patterns.md` before creating or appending workflow recipes. Add a `videoMerge` node when the user wants one final combined video.
9. Run only after the user asks to generate and `actions` permission is enabled. Run `videoMerge` only after all source clips are complete. Export ordered clips or the final merge output only after `project_export` permission is enabled.

## Output Contract

When planning, return:

- `scriptTitle`
- `targetDuration`
- `platform`
- `hook`
- `scenePlan`: ordered scenes with `sceneId`, duration, purpose, visual action, spoken line, transition, and suggested node ids
- `assetManifest`: shared characters, props/products, wardrobe, locations, style refs, and voice inputs that must exist before video generation
- `workflowPlan`: node/edge outline with explicit handles
- `runPlan`: which nodes can run in parallel and which depend on upstream images/text
- `handoffPlan`: expected exported clip filenames in scene order, plus the merged output filename when using `videoMerge`

Do not claim a video will go viral. Say "viral-style" or "optimized for short-form retention".

## Important Limits

VeoGenie supports a local `videoMerge` node for ordered lossless merging of finished video clips. Use it when the user asks for one final combined video and MCP capabilities/recipe contract include `videoMerge`.

If the user asks for one final complete video, create ordered clips such as:

```text
render/<job-slug>/scene-01-hook.mp4
render/<job-slug>/scene-02-setup.mp4
render/<job-slug>/scene-03-proof.mp4
render/<job-slug>/scene-04-payoff.mp4
render/<job-slug>/scene-05-cta.mp4
```

Then connect those clip nodes to:

```text
videoGenerate:video -> videoMerge:video
videoGenerate:video -> videoMerge:video
videoGenerate:video -> videoMerge:video
```

Run/export the `videoMerge` node as `render/<job-slug>/final-merged.mp4` after all source clips are `success`.

## Quality Rules

- The hook must start with tension, curiosity, consequence, proof, or a surprising visual. Avoid logo intros and generic greetings.
- Every scene must move the story forward. Do not make filler clips.
- Use one main idea per scene. Do not ask one `videoGenerate` node for multiple unrelated locations or time jumps.
- Spoken lines must sound like a person speaking in the requested language, not an assistant explaining a concept.
- If one consistent voice is needed, create one `voiceReference` node and connect it to every `videoGenerate:video-voice-reference`.
- If a scene includes a named/important character, product, prop, outfit, or location that is not in the user inputs, create a reusable reference image before running that scene.
- Use one `videoGenerate` node per scene; do not use `resultCount` as a substitute for different story beats.
- Use `resultCount` only for variants of the same scene, such as testing two hook deliveries, when the user asks for variants.
- Do not run `videoMerge` until at least two connected source video nodes are complete and verified from app state.
