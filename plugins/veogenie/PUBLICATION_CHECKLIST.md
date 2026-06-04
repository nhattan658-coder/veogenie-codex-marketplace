# VeoGenie Codex Plugin Publication Checklist

Use this checklist before copying this plugin into a public repository.

## App Release

- Build and publish a VeoGenie Tool installer that includes:
  - root `veogenie-mcp.cmd` in the selected install directory
  - `runtime\mcp-server\index.mjs` in the selected install directory
  - `runtime\node\node.exe` in the selected install directory
- The public plugin must use `bin\veogenie-mcp-launcher.cmd`; it must not hard-code `C:`, `D:`, or `E:` in `.mcp.json`.
- If the user installs VeoGenie into a custom directory outside the common install paths, document `VEOGENIE_MCP_LAUNCHER=<full path to veogenie-mcp.cmd>` or create a stable launcher at `%LOCALAPPDATA%\VeoGenie\veogenie-mcp.cmd`.
- Install the release build on a clean Windows machine or VM.
- Open the desktop app and verify:

```powershell
Invoke-RestMethod http://127.0.0.1:8788/health
```

## Plugin Metadata

Verify the public metadata in:

```text
.codex-plugin/plugin.json
```

Required values:

- publisher name
- contact email
- publisher URL
- documentation/homepage URL
- public plugin repository URL
- license
- website URL
- privacy policy URL
- terms of service URL

The current public target is:

```text
https://github.com/nhattan658-coder/veogenie-codex-marketplace
```

The policy/license files must be present before export:

```text
PRIVACY.md
TERMS.md
LICENSE.md
```

Agent instruction files must also be present before export:

```text
AGENTS.md
CLAUDE.md
```

Required skill folders must be present before export:

```text
skills/veogenie
skills/veogenie-workflow-designer
skills/veogenie-model-selector
skills/veogenie-image-to-video-input-planner
skills/veogenie-continuity-asset-planner
skills/veogenie-viral-video-producer
skills/veogenie-product-ad
skills/veogenie-video-director
skills/veogenie-result-qa
skills/veogenie-project-memory
```

The plugin launcher resolver must be present before export:

```text
bin/veogenie-mcp-launcher.cmd
```

The result QA skill must include:

```text
skills/veogenie-result-qa/references/result-handoff-checklist.md
skills/veogenie-result-qa/references/semantic-result-qa.md
```

The viral video producer skill must include:

```text
skills/veogenie-viral-video-producer/references/viral-script-structures.md
skills/veogenie-viral-video-producer/references/natural-dialogue-rubric.md
skills/veogenie-viral-video-producer/references/multi-scene-workflow-patterns.md
```

The continuity asset planner skill must include:

```text
skills/veogenie-continuity-asset-planner/references/continuity-asset-manifest.md
skills/veogenie-continuity-asset-planner/references/preproduction-workflow-patterns.md
```

The image-to-video input planner skill must include:

```text
skills/veogenie-image-to-video-input-planner/references/minimal-video-input-routing.md
skills/veogenie-image-to-video-input-planner/references/image-first-patterns.md
```

`npm run plugin:export` rejects plugin metadata if any public plugin metadata file still contains local-test URLs.

## Plugin Export

From the app repo root, run:

```powershell
npm run plugin:export
```

The export output is:

```text
dist/codex-plugin/veogenie
```

Use that folder when copying the plugin into an existing marketplace repo at `plugins/veogenie`.

For a standalone repo/folder that Codex can add directly as a marketplace, use:

```text
dist/codex-marketplace
```

This folder contains `.agents/plugins/marketplace.json` plus `plugins/veogenie`, and does not contain the desktop app source.
It also includes root-level `AGENTS.md` and `CLAUDE.md` so Codex and Claude can read the basic node/input/voice workflow before using the plugin.

If publishing via GitHub, push the standalone marketplace root so Codex can add the repo with:

```text
Source: https://github.com/<owner>/veogenie-codex-marketplace.git
Git ref: main
Sparse paths: leave empty
```

After adding the marketplace, verify the plugin is enabled. If the UI does not expose an install button, document the fallback:

```toml
[plugins."veogenie@veogenie-marketplace"]
enabled = true
```

## Default Safety

- Keep `.mcp.json` read-only by default.
- Do not enable `VEOGENIE_MCP_ALLOW_ACTIONS`, `VEOGENIE_MCP_ALLOW_CANVAS_WRITE`, `VEOGENIE_MCP_ALLOW_MEDIA_EXPORT`, `VEOGENIE_MCP_ALLOW_MEDIA_IMPORT`, `VEOGENIE_MCP_ALLOW_PROJECT_EXPORT`, or `VEOGENIE_MCP_ALLOW_RUN` by default.
- `grant_mcp_session_permissions` may be available, but it must only grant temporary permissions after the user explicitly approves the action in chat.
- Keep `run_workflow_payload` env-only via `VEOGENIE_MCP_ALLOW_RUN=1`; do not allow session grants for raw workflow payloads.
- Document guarded tools as opt-in only.
- Keep `AGENTS.md` and `CLAUDE.md` short and practical: node roles, correct input routing, shared voice wiring, basic run/poll/export flow.
- Document video routing intent: frame/keyframe requests use `frame-start`/`frame-end`; synchronized voice/narration requests use `video-reference-image` plus `video-voice-reference` unless exact first/last frames are explicitly requested.
- Document result handoff simply: Codex should read `get_node_outputs` and node-specific `get_media_album`, then export `mediaId` values if files are needed.
- Document project-memory behavior without enabling silent writes: agents may update the user's `AGENTS.md`, `CLAUDE.md`, `DESIGN.md`, or `BUSINESS_RULES.md` only after explicit feedback/approval.
- Do not include source app code, license issuer/private key, admin routes, media payloads, or customer data in the public plugin repository.

## Smoke Test

With the app open, ask Codex:

```text
Use the VeoGenie MCP plugin to call get_mcp_capabilities, get_app_status, list_pages, and get_current_workflow.
Optionally call build_product_ad_workflow_recipe with a sample product brief and confirm it only returns a recipe.
Optionally call get_run_orchestration_status with a known nodeId only after confirming it is read-only and does not queue a run.
Do not run Google Flow, ChatGPT, GPT Image 2, create/append pages, import media, export files, run_node, run_group, or run_workflow_payload.
```
