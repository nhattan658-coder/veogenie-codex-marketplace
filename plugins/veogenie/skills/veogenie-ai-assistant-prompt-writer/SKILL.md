---
name: veogenie-ai-assistant-prompt-writer
description: Decide whether Codex should write a VeoGenie image/video prompt directly or use an aiAssistant / Tro Ly AI node as a runtime prompt writer, then design, run, and verify the chosen prompt-authoring flow. Use when a request involves prompt improvement, prompt variants, reusable or dynamic prompt generation, image-grounded prompt writing, scripts or shot lists produced inside the workflow, or deciding whether an AI Assistant node adds value before imageGenerate or videoGenerate.
---

# VeoGenie AI Assistant Prompt Writer

## Core Rule

Let Codex write the final prompt directly by default. An `aiAssistant` node does not inherently make a prompt better; it adds a runtime transformation step, latency, and another failure point.

Use `aiAssistant` only when prompt generation must be part of the reusable workflow or depend on runtime inputs.

## Choose The Authoring Mode

Use **Codex-direct mode** when:

- The user supplied a clear brief and needs a final prompt now.
- The prompt is for a one-off image/video run.
- Codex already has the relevant brief, references, and project rules in context.
- No runtime image/text output must be interpreted before writing the prompt.
- Reliability and fewer automation steps matter more than preserving a prompt-writing stage on canvas.

Use **AI-Assistant mode** when:

- The prompt must change when connected text, images, or upstream outputs change.
- The workflow will be rerun with different inputs.
- The user wants prompt variants, scripts, shot lists, captions, or intermediate text selectable on canvas.
- An attached image or runtime media input must be analyzed before producing the downstream prompt.
- The user explicitly wants `Tro Ly AI` to write or improve prompts inside VeoGenie.

Do not add `aiAssistant` merely to rewrite a final prompt Codex can already provide.

## Codex-Direct Mode

1. Use the relevant creative skill such as `veogenie-video-director`, `veogenie-product-ad`, or `veogenie-viral-video-producer`.
2. Write one production-ready prompt that preserves the user's constraints.
3. Put the prompt in a `textPrompt` node and connect it directly:

```text
textPrompt:text -> imageGenerate:text
textPrompt:text -> videoGenerate:text
```

4. Use `veogenie-workflow-designer` for recipe creation or canvas changes.

## AI-Assistant Mode

Codex still owns the assistant instruction, workflow structure, and quality check. The assistant node transforms direct runtime inputs into final prompt text.

Use explicit handles:

```text
textPrompt:text -> aiAssistant:text
imageReference:image -> aiAssistant:image
aiAssistant:text -> imageGenerate:text
aiAssistant:text -> videoGenerate:text
```

Use `aiAssistant:assistant-text:N` only when selecting one specific zero-based batch variant. Do not connect every variant to one downstream node unintentionally.

Keep inputs direct. Do not pull unrelated upstream text, images, or generated variants into the assistant.

## Assistant Instruction Contract

Write the assistant instruction with four parts:

1. **Task**: state whether it must produce an image prompt, video prompt, script, shot list, or variants.
2. **Runtime inputs**: explain how to use connected text/images without inventing missing identity details.
3. **Invariants**: preserve product, character, brand, continuity, language, format, and user constraints.
4. **Output contract**: request only final usable text, without analysis or markdown unless the user wants it.

Default pattern:

```text
Create [one / N] production-ready VeoGenie [image/video] prompt(s) from the connected brief and references.
Preserve all explicit identity, product, continuity, language, format, and safety constraints.
Include concrete subject action, composition, camera, lighting, environment, motion, and exclusions relevant to the requested output.
Return only the final prompt text or numbered prompt variants. Do not include analysis, headings, or unrelated copy.
```

Add domain-specific requirements from `veogenie-product-ad`, `veogenie-video-director`, or other relevant skills instead of relying on generic wording.

## Run And Verify

1. Inspect the current workflow with `get_current_workflow`.
2. Run `aiAssistant` only after its required direct inputs exist and `actions` permission is enabled.
3. Poll with `get_run_orchestration_status`; do not submit the same assistant node twice while queued, dispatched, or running.
4. Read the assistant result with `get_node_outputs`.
5. Check that the output is usable prompt text, preserves constraints, and contains no analysis or unintended instructions.
6. Run downstream image/video nodes only after the assistant output is verified.

If the output is vague, drops constraints, or returns commentary instead of a prompt, update the assistant instruction and rerun only after the previous command is finished. Do not hide an unusable assistant output by running downstream generation anyway.

## Failure And Fallback

- `aiAssistant` uses the ChatGPT Chrome debug session. If the session or port `9222` is unavailable, report the session issue clearly.
- Fall back to Codex-direct mode only when the user does not require prompt generation to remain inside the workflow.
- Keep an existing assistant stage when it is intentionally reusable or consumes runtime inputs; do not remove it solely to reduce latency.

