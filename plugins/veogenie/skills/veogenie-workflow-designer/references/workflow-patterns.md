# VeoGenie Workflow Patterns

## Product Image Set

Use when the user wants product images, thumbnails, hero images, marketplace images, or social post visuals.

Recommended shape:

1. `imageReference` for the product photo.
2. `textPrompt` for the product-shot direction.
3. Optional `aiAssistant` to rewrite the prompt into a tighter production prompt.
4. `imageGenerate` for generated variants.

Quality notes:

- Preserve the product's visible identity, packaging, color, proportions, and logo placement.
- Change environment, lighting, props, and composition rather than inventing a different product.
- Generate multiple variants only when the user wants options or the brief is broad.

## Product Video Ad

Use when the user wants a product video, social ad, launch spot, or animated product scene.

Recommended shape:

1. `imageReference` for the product photo.
2. `textPrompt` for campaign intent and visual direction.
3. `imageGenerate` for a clean hero frame or key visual.
4. Optional `aiAssistant` for shot direction or voice/script.
5. `videoGenerate` using the hero frame as the start frame or visual reference.

Dependency rules:

- Do not run video until upstream image output is `success`.
- Use `frame-start` for a deliberate opening frame.
- Use `frame-end` only when the user asks for a specific ending state.
- Use `video-reference-image` for additional visual references that are not start/end frames.

## Prompt Development Workflow

Use when the user asks for a better prompt, style exploration, storyboard, or creative direction but does not ask to generate media yet.

Recommended shape:

1. `textPrompt` for the user's rough brief.
2. `aiAssistant` to produce structured prompt(s), shot list, or variants.
3. Optional downstream image/video nodes only after the user asks to build or run the workflow.

## Existing Workflow Review

Use when the user asks whether a workflow is ready.

Check:

- Output node has a valid prompt or assistant text dependency.
- Required image/frame/voice inputs are connected directly to the output node.
- No locked `characterReference` dependency is present.
- Result count, aspect ratio, model, and duration fit the user request.
- No output node is running before edits or page changes.
