# Continuity Asset Manifest

Use this manifest before creating multi-scene video workflows. It decides which inputs must exist before `videoGenerate` nodes run.

## Asset Types

- `character`: main speaker, supporting actor, customer, employee, child, villain, presenter, avatar, mascot.
- `wardrobe`: outfit, uniform, accessories, makeup, hair state, costume version.
- `prop`: phone, bag, tool, document, package, food, vehicle, hero object.
- `product`: product, packaging, logo-safe product appearance, variant, bundle.
- `location`: room, storefront, street, office, studio, kitchen, background set.
- `style`: recurring lighting, color grade, camera look, illustration/photo style.
- `voice`: shared narrator, character voice, speaker tone.

## Manifest Fields

Use stable ids so later workflow nodes can reference assets clearly:

```text
assetId: char-main-founder
type: character
name: Linh
state: provided | missing | generated-upstream | scene-only
continuityScope: global | recurring | scene
sceneUses: scene-01, scene-02, scene-04
createBeforeVideo: true | false
modelHint: gpt-image-2 | gemini-3-pro-image-preview | gemini-2.5-flash-image
nodeIds: ref-char-linh, prompt-char-linh, image-char-linh
promptLock: short description that must stay consistent in scene prompts
```

## Creation Rules

- If an asset is named, plot-critical, visually inspected by the viewer, or appears in two or more scenes, mark `createBeforeVideo=true`.
- If the script introduces a second important character and the user provided only the first character, create a new character reference before any video scene that uses that second character.
- If a character changes outfit intentionally, create versioned assets such as `char-linh-outfit-a` and `char-linh-outfit-b`; do not silently change wardrobe across scenes.
- If a product or prop is central to the hook, payoff, reveal, or CTA, create or attach a reference even if it appears once.
- If a background must be recognized again, create or attach a location reference. If it is generic and appears once, keep it in the scene prompt.
- If a voice must stay consistent, create one `voiceReference` node and connect it to every target `videoGenerate:video-voice-reference`.

## Example

Initial user input:

```text
One image of Linh, the main character.
```

Script:

```text
Scene 1: Linh opens a mystery package.
Scene 2: Minh, the delivery guy, argues with Linh.
Scene 3: A cafe owner reveals the package contents.
Scene 4: Linh and Minh return to the same cafe.
```

Asset decision:

- `char-linh`: provided image, global, use in scenes 1-4.
- `char-minh`: missing important character, create before video, use in scenes 2 and 4.
- `char-cafe-owner`: supporting but reveal-critical, create before video if the face must be consistent; otherwise scene-only if background role.
- `prop-mystery-package`: plot-critical, create before video.
- `loc-cafe`: recurring location, create or attach a reference before scenes 3 and 4.

The agent should generate these reusable inputs first, then route them into the relevant video scene nodes.
