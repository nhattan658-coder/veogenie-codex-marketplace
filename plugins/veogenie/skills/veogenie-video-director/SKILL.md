---
name: veogenie-video-director
description: Direct VeoGenie video workflows and prompts. Use when Codex needs to create or improve video generation prompts, storyboard short ads, choose start/end frames, handle video reference images or voice references, set duration/model guidance, or plan a safe video run through the VeoGenie MCP plugin.
---

# VeoGenie Video Director

## Scope

Use this skill for video creative direction. Use the core `veogenie` skill for MCP permissions, run/poll behavior, and result handoff.

## Default Process

1. Identify the clip purpose, output duration, aspect ratio, subject, start state, end state, and motion.
2. Check whether the video needs a generated hero frame first.
3. Use direct text input from `textPrompt` or `aiAssistant.generatedText`.
4. Use `frame-start` and `frame-end` only for deliberate start/end states.
5. Use `video-reference-image` for supporting images that should influence the scene but are not start/end frames.
6. Use `video-voice-reference` only for voice direction or saved/custom Flow voice.
7. Do not run video until upstream image/text dependencies are complete.

## Prompt Standards

Write video prompts as production direction:

- Subject: what must remain visually consistent.
- Scene: location, set, surface, atmosphere, and props.
- Camera: shot size, lens feel, movement, speed, and framing.
- Motion: product/action movement over time.
- Lighting: stable lighting style and reflection behavior.
- Timing: simple beginning, middle, and ending beat for short clips.
- Constraints: no extra text, no logo changes, no warped product, no abrupt scene jump.

## Model And Duration

- For `Omni Flash`, treat duration as an explicit setting when available.
- For `Veo 3.1` Lite/Fast/Quality, use the app's current default duration behavior unless the app exposes duration controls.
- Keep short ad prompts focused. A 6-8 second clip should have one main action, not a full narrative.

## Voice Rules

- For preset voices in the app's voice list, use prompt guidance when the current Flow picker does not expose a voice tab.
- For custom/saved Flow voices, use the picker path only when the voice must be attached and verified.
- If the required custom voice cannot be verified, stop before `Generate`.

## Locked Character Rule

Do not add or depend on `characterReference` / `Nhan Vat` while it is locked. Character description can be plain prompt context only when it is not required as a Flow character chip.

## References

Read `references/video-prompt-rubric.md` when writing a video prompt, shot list, or short ad structure.
