# Multi-Scene VeoGenie Workflow Patterns

Use these patterns to turn a viral script into ordered VeoGenie clips.

## Current Capability Boundary

VeoGenie can create `videoGenerate` outputs, merge finished clips with `videoMerge`, and export generated media. If the user asks for one final combined video, add a `videoMerge` node after the scene clips and export that node's media. If no merge node is present in the actual app/MCP snapshot, report ordered clips only.

## Pattern A: Direct Multi-Scene Video

Use when all scenes can be generated from prompt text plus optional shared references.

For each scene:

- `textPrompt`: scene-specific video prompt and spoken line.
- `videoGenerate`: scene clip output.

Optional shared nodes:

- `imageReference`: product/person/style reference.
- `voiceReference`: one shared voice for all scenes.
- `videoMerge`: optional final combined output after all scenes finish.
- `group`: contains the full short-form sequence.

Edges for each scene:

```text
textPrompt:text -> videoGenerate:text
imageReference:image -> videoGenerate:video-reference-image
voiceReference:voice -> videoGenerate:video-voice-reference
```

Use `video-reference-image` for visual continuity references. Use `frame-start` only when an image must be the exact first frame.

Optional merge edges after scene clips:

```text
videoGenerate:video -> videoMerge:video
videoGenerate:video -> videoMerge:video
videoGenerate:video -> videoMerge:video
```

## Pattern B: Storyboard Frames Then Video

Use when the user wants tighter visual continuity or exact opening frames.

For each scene:

- `textPrompt`: storyboard frame prompt.
- `imageGenerate`: creates the scene opening frame.
- `textPrompt`: video motion/dialogue prompt.
- `videoGenerate`: creates the scene clip.

Edges:

```text
textPrompt:text -> imageGenerate:text
imageGenerate:image -> videoGenerate:frame-start
textPrompt:text -> videoGenerate:text
imageReference:image -> videoGenerate:video-reference-image
voiceReference:voice -> videoGenerate:video-voice-reference
```

Use `gpt-image-2` for realistic storyboard/keyframe frames unless the user asks for high-resolution final image renders.

Before wiring video inputs, use `veogenie-image-to-video-input-planner` to prune redundant references. If a generated frame already contains the full outfit, product, prop, or location, do not also feed separate refs for the same details unless fidelity is at risk.

## Pattern C: UGC Or Character-Led Viral Sequence

Use when one speaker or character appears across several clips.

Shared nodes:

- `imageReference`: speaker/character reference, if provided.
- `voiceReference`: exact built-in voice preset.

Per scene:

- `textPrompt`: natural dialogue and action.
- `videoGenerate`: one clip.

Edges:

```text
imageReference:image -> videoGenerate:video-reference-image
voiceReference:voice -> videoGenerate:video-voice-reference
textPrompt:text -> videoGenerate:text
```

Keep the same speaker persona and voice notes in every scene prompt.

## Pattern D: Continuity Assets Before Scene Videos

Use when a script introduces multiple important characters or recurring products, props, outfits, or locations. Create these reusable inputs before running scene video nodes.

Pre-production branches:

```text
textPrompt:text -> imageGenerate:text
imageReference:image -> imageGenerate:image
```

Scene video edges:

```text
textPrompt:text -> videoGenerate:text
imageGenerate:generatedAsset -> videoGenerate:video-reference-image
imageReference:image -> videoGenerate:video-reference-image
voiceReference:voice -> videoGenerate:video-voice-reference
```

If the user supplied only one main character but the script adds more important characters, make separate character reference branches for each missing character first. Use `frame-start` only for a generated storyboard image that must be the exact first frame.

## Pattern E: Fashion Or Look-Driven Scene

Use when the scene depends on a precise outfit, styling, runway/lookbook composition, or model pose. Generate the fashion look first, then use a minimal video input set.

Pre-production:

```text
textPrompt:text -> imageGenerate:text
optional face/imageReference:image -> imageGenerate:image
optional garment/imageReference:image -> imageGenerate:image
```

Scene video:

```text
imageGenerate:generatedAsset -> videoGenerate:frame-start
textPrompt:text -> videoGenerate:text
optional face/imageReference:image -> videoGenerate:video-reference-image
```

Omit garment/wardrobe refs from `videoGenerate` when the generated fashion still already shows the final outfit clearly. Keep only face/identity refs if character identity matters.

## Node Naming

Use stable ids and readable titles:

```text
prompt-scene-01-hook
video-scene-01-hook
prompt-scene-02-setup
video-scene-02-setup
voice-shared
ref-product-main
group-viral-short
merge-final
prompt-char-supporting
image-char-supporting
prompt-fashion-look
image-fashion-look
```

## Run Plan

- If scenes only depend on shared reference images and prompts, queue all `videoGenerate` nodes in the same scheduling pass with separate `run_node` calls.
- If scenes depend on generated storyboard frames, run all ready `imageGenerate` nodes first, verify outputs, then run the dependent `videoGenerate` nodes.
- Run `videoMerge` only after at least two connected source video nodes are `success` and have generated video assets.
- Do not queue a scene twice while its command is `queued`/`dispatched` or output is `running`.
- Use `run_group` only when the user wants the app to enforce group dependencies.

## Export Plan

After QA, export in scene order:

```text
render/<job-slug>/scene-01-hook.mp4
render/<job-slug>/scene-02-setup.mp4
render/<job-slug>/scene-03-escalation.mp4
render/<job-slug>/scene-04-payoff.mp4
render/<job-slug>/scene-05-cta.mp4
render/<job-slug>/final-merged.mp4
```

Poll `get_command_status` after every export. If an export fails, refresh app state and retry that media id at most once.

When the user wants one final file, export `final-merged.mp4` from the `videoMerge` node after verifying the merge node output with `get_node_outputs` and node-specific `get_media_album(type="video")`.
