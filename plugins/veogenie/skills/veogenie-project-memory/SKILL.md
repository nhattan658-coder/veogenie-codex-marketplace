---
name: veogenie-project-memory
description: Capture durable user feedback after VeoGenie work and update the user's project memory files such as AGENTS.md, CLAUDE.md, DESIGN.md, and BUSINESS_RULES.md. Use when the user says a VeoGenie result, workflow, prompt, design, or process was right or wrong and asks the agent to remember, avoid, apply next time, update rules, or keep project-specific preferences.
---

# VeoGenie Project Memory

Use this skill only for durable project guidance. Do not write memory files for every casual reaction.

## When To Use

Use this skill when the user explicitly says or clearly implies:

- "Remember this", "save this rule", "next time do it like this".
- "This is correct", "this is the style I want", "keep this direction".
- "This is wrong", "avoid this", "do not do this again".
- "Update AGENTS/CLAUDE/DESIGN/BUSINESS_RULES".

If the feedback is ambiguous, ask one short confirmation before editing files.

## Files

Prefer existing files. If a file is missing and the user approved a memory update, create it in the project root with concise content.

- `AGENTS.md`: agent operating process, required startup reads, tool usage rules, handoff workflow, retry limits.
- `CLAUDE.md`: short companion guide for Claude-style agents; mirror only the most important working rules.
- `DESIGN.md`: visual direction, brand style, composition preferences, prompt style, examples of approved/rejected looks.
- `BUSINESS_RULES.md`: durable domain rules, product constraints, compliance rules, must-do and must-not-do behavior.

Do not put long task history into these files. Put only rules likely to stay useful across sessions.

## How To Update

1. Read existing memory files before editing.
2. Preserve existing user content and structure.
3. Add or update a small section such as `## VeoGenie Preferences`, `## Design Feedback`, or `## Generation Rules`.
4. Convert positive feedback into reusable guidance.
5. Convert negative feedback into an avoid rule plus the desired correction.
6. Keep entries concrete: mention product, style, prompt constraint, workflow pattern, or output criterion.
7. Avoid storing raw media, private data, API keys, generated base64, or temporary file paths.
8. Report exactly which files changed and what rule was added.

## Examples

Positive feedback:

```text
DESIGN.md
- VeoGenie product images should use clean premium lighting, centered product framing, and no visible text overlays unless requested.
```

Negative feedback:

```text
BUSINESS_RULES.md
- Do not generate ad videos with extra people beside the provided product unless the user explicitly asks for a human model.
```

Process feedback:

```text
AGENTS.md
- Before running VeoGenie video nodes, confirm whether the provided product image is a strict first frame or only a reference image.
```

## Safety

- Do not silently modify project memory after every VeoGenie run.
- Do not treat a single failed generation as a permanent rule unless the user says to remember it.
- Do not overwrite or delete existing project rules to fit the latest result.
- If user feedback conflicts with an existing rule, point out the conflict and ask before changing it.
