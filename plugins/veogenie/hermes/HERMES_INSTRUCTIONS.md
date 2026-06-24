# VeoGenie Hermes Agent Instructions

Use these instructions when Hermes Agent controls the local VeoGenie desktop app through MCP.

This package is not a Codex marketplace plugin. It is a Hermes-friendly MCP and skills bundle built from the same VeoGenie skill docs. If Hermes can attach a folder of instructions or knowledge files, attach this package root and the `skills/` folder. If Hermes cannot auto-load folders, paste this file into Hermes project/system instructions and ask it to read the relevant skill files before acting.

## Required Local App State

The customer machine must have VeoGenie Tool Agent installed. The app can be opened manually, or Hermes can call `open_installed_app` after the user asks it to control VeoGenie.

When the user wants Hermes to prepare Google Flow browser/login access, Hermes can call `open_google_flow_login` with `confirmOpenGoogleFlowLogin=true` after the app/backend is reachable. The user may still need to finish Google login, 2FA, or captcha in the opened browser.

Before doing anything else, verify the local backend:

```powershell
Invoke-RestMethod http://127.0.0.1:8788/health
```

Expected:

```json
{ "ok": true }
```

If the backend is not reachable, call `open_installed_app` with `confirmOpenApp=true` only after the user asked Hermes to open/control VeoGenie. Then retry `get_app_status`. If it still fails, stop and ask the user to open VeoGenie Tool Agent manually.

## MCP Startup

Configure Hermes with the MCP server from `mcp-config.json`.

The MCP launcher is:

```text
bin/veogenie-mcp-launcher.cmd
```

The launcher resolves the installed app launcher without assuming a fixed drive. It checks `VEOGENIE_MCP_LAUNCHER`, `%LOCALAPPDATA%`, `%ProgramData%`, `%ProgramFiles%`, `%ProgramFiles(x86)%`, and common `C:`, `D:`, and `E:` install paths.

If the app is installed in a custom directory, set:

```powershell
setx VEOGENIE_MCP_LAUNCHER "C:\Path\To\VeoGenie Tool Agent\veogenie-mcp.cmd"
```

Then restart Hermes.

## First Read-Only Checks

At the start of every Hermes session, call these tools first:

1. `get_mcp_capabilities`
2. `get_app_status`
3. `open_installed_app` with `confirmOpenApp=true` only if `get_app_status` is unreachable and the user asked Hermes to open/control VeoGenie
4. `open_google_flow_login` with `confirmOpenGoogleFlowLogin=true` only if the user asked Hermes to prepare Google Flow browser/login access
5. `list_pages`
6. `get_current_workflow`

Report the active page name and node/edge count before making changes.

## Skill Loading Rules

Use the files in `skills/` as the agent's operating manual.

Recommended routing:

- `skills/veogenie/SKILL.md`: app connection, MCP permissions, run/poll/export flow.
- `skills/veogenie-workflow-designer/SKILL.md`: workflow recipes, node types, edge handles, and port rules.
- `skills/veogenie-workflow-designer/references/node-port-contract.md`: authoritative handle contract.
- `skills/veogenie-product-ad/SKILL.md`: product image/video ads.
- `skills/veogenie-video-director/SKILL.md`: high-quality video prompts.
- `skills/veogenie-model-selector/SKILL.md`: image/video model choice.
- `skills/veogenie-image-to-video-input-planner/SKILL.md`: image-first video input routing.
- `skills/veogenie-continuity-asset-planner/SKILL.md`: reusable characters, products, props, locations, wardrobe, and style refs.
- `skills/veogenie-viral-video-producer/SKILL.md`: multi-scene short video scripts and clip workflows.
- `skills/veogenie-ai-assistant-prompt-writer/SKILL.md`: decide when to use an `aiAssistant` / `Tro Ly AI` prompt-writing node.
- `skills/veogenie-result-qa/SKILL.md`: result verification and export handoff.
- `skills/veogenie-project-memory/SKILL.md`: update user project memory only after explicit user approval.

Before creating or editing a workflow, read `veogenie-workflow-designer/SKILL.md` and `references/node-port-contract.md`.

Before choosing or changing an image/video model, read `veogenie-model-selector/SKILL.md`. For Gemini web video models (`gemini-3.1-flash-lite-video`, `gemini-3.5-flash-video`, `gemini-3.1-pro-video`), set `geminiThinkingLevel` to `standard` for simple/fast prompts and `extended` for complex, product-fidelity, or high-constraint prompts. Do not set `geminiThinkingLevel` on Google Flow/labs models.

Before running or reporting results, read `veogenie/SKILL.md` and `veogenie-result-qa/SKILL.md`.

## Permission And Guard Rules

Default mode has no workflow write/run permissions. Do not run, write, import, or export until the user explicitly approves the action.

Read-only tools can be used without extra approval:

- `get_mcp_capabilities`
- `get_app_status`
- `open_installed_app` with `confirmOpenApp=true` when the user asked Hermes to open/control the installed app
- `list_pages`
- `get_current_workflow`
- `get_node_outputs`
- `get_media_album`
- `build_product_ad_workflow_recipe`
- `plan_product_ad_job`
- `get_command_status`
- `get_run_orchestration_status`

Guarded actions require user approval and the matching session permission or environment guard:

- Canvas writes: `canvas_write`
- Media import: `media_import`
- Run node/group: `actions`
- Native save dialog export: `media_export`
- Workspace render export: `project_export`

If the MCP tool `grant_mcp_session_permissions` is available, use it only after the user approves the exact permission. Session grants expire and do not persist across Hermes/plugin restarts.

Never enable all permissions by default.

`run_workflow_payload` is advanced and env-only. Do not use it for normal Hermes jobs.

`open_installed_app` is open-only. Hermes must not close, kill, or restart the VeoGenie desktop app through MCP.

## Workflow Edge Rules

Always set explicit `sourceHandle` and `targetHandle` in workflow recipes.

Common valid edges:

```text
textPrompt:text -> imageGenerate:text
imageReference:image -> imageGenerate:image
textPrompt:text -> videoGenerate:text
aiAssistant:text -> videoGenerate:text
imageGenerate:image -> videoGenerate:frame-start
imageGenerate:image -> videoGenerate:frame-end
imageReference:image -> videoGenerate:video-reference-image
voiceReference:voice -> videoGenerate:video-voice-reference
videoGenerate:video -> videoMerge:video
videoMerge:video -> videoMerge:video
```

Do not rely on default handle inference for `videoGenerate` or `videoMerge`.

## Video Rules

Use `frame-start` and optional `frame-end` only when the user wants exact first/last frames or keyframes.

Use `video-reference-image` for style, product, character, fashion, or visual references that are not exact first/last frames.

Use `video-voice-reference` for shared voice or narration. Do not put voice names or voice descriptions into the text prompt as a replacement for the voice picker.

## Video Merge Rules

Use `videoMerge` only when the user wants one final combined video from two or more finished clips.

Only valid inputs:

```text
videoGenerate:video -> videoMerge:video
videoMerge:video -> videoMerge:video
```

Do not connect text, image, or voice nodes into `videoMerge`.

Do not run `videoMerge` until at least two connected upstream video nodes are `success` and each has a generated video asset.

When the user asked for one final combined file, report and export the media from the `videoMerge` node, not from the individual clips.

## Result Source Of Truth

VeoGenie app state is the only source of truth for generated results.

After running a node or group:

1. Poll `get_command_status` or `get_run_orchestration_status`.
2. Read `get_node_outputs`.
3. Read `get_media_album` with the exact output `nodeId`, `source="generated"`, and the expected media `type`.
4. Only report media ids and exported files that come from app state.

Do not create or show separate chat-generated media and call it a VeoGenie result.

If the user wants files, export by `mediaId` through `export_media` or `export_media_to_workspace` after the matching permission is enabled.

## Retry Discipline

Do not submit the same node repeatedly while a command is `queued`, `dispatched`, or the node output is `running`.

If semantic QA fails, retry the same node/group at most once with a specific correction prompt. If the retry fails, report `fail` or `partial` and stop.

## Project Memory

Only update project memory files when the user explicitly asks to remember, avoid, apply next time, or update rules.

Do not store raw media, base64, private keys, license data, or temporary file paths in memory docs.
