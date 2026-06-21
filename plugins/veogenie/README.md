# VeoGenie Codex Plugin

This plugin connects Codex to the locally installed VeoGenie desktop app through MCP.

## Requirements

1. Install VeoGenie Tool.
2. Open the desktop app, or let the agent call `open_installed_app` with `confirmOpenApp=true` after you ask it to control VeoGenie.
3. If Google Flow login/debug Chrome is not already open, ask the agent to call `open_google_flow_login` with `confirmOpenGoogleFlowLogin=true`, then log in once in that browser if Google asks.
4. Confirm the local backend is running:

```powershell
Invoke-RestMethod http://127.0.0.1:8788/health
```

The expected response is:

```json
{ "ok": true }
```

## MCP Launcher

The plugin starts a bundled resolver:

```text
plugins/veogenie/bin/veogenie-mcp-launcher.cmd
```

The resolver then finds the installed app launcher without assuming a fixed drive. It checks, in order:

- `VEOGENIE_MCP_LAUNCHER` when set to a full launcher path.
- `%LOCALAPPDATA%\VeoGenie\veogenie-mcp.cmd`
- `%ProgramData%\VeoGenie\veogenie-mcp.cmd`
- common install paths under `%LOCALAPPDATA%\Programs`, `%ProgramFiles%`, `%ProgramFiles(x86)%`, `C:\`, `D:\`, and `E:\`.

On Windows, the desktop app also writes `%LOCALAPPDATA%\VeoGenie\veogenie-mcp.cmd` on startup when the installed root launcher exists, so custom install directories can still be resolved after the user opens the app once.

The installed app launcher starts the MCP server bundled with the desktop app and connects to:

```text
http://127.0.0.1:8788
```

If the MCP server is available but the desktop app/backend is not running, the agent can call `open_installed_app` to launch the installed app and then probe `/health` again. This tool is open-only: it does not close, kill, restart, or run workflow automation.

After the app/backend is reachable, the agent can call `open_google_flow_login` with `confirmOpenGoogleFlowLogin=true` when the user asks it to prepare Google Flow access. The open app runs the same action as the desktop "Dang nhap Google Flow" button: it opens Chrome/Edge with the managed Google Flow debug profile on port `9222`. The tool does not run a workflow or click Generate.

## Default Permissions

The default `.mcp.json` has no workflow write/run permissions. It lets Codex call tools such as:

- `get_mcp_capabilities`
- `get_app_status`
- `open_installed_app` with `confirmOpenApp=true` when the user asked the agent to open/control the installed app
- `open_google_flow_login` with `confirmOpenGoogleFlowLogin=true` when the user asked the agent to open/prepare Google Flow login
- `list_pages`
- `get_current_workflow`
- `get_node_outputs`
- `get_media_album`
- `build_product_ad_workflow_recipe`
- `plan_product_ad_job`
- `get_command_status`
- `get_run_orchestration_status`

## Included Skills

The plugin includes several skills for AI Agent work:

- `veogenie`: safe MCP startup, permissions, run/poll, and result handoff.
- `veogenie-ai-assistant-prompt-writer`: decide whether Codex should write a final prompt directly or use `aiAssistant` / `Tro Ly AI` for dynamic, reusable, runtime-grounded prompt generation.
- `veogenie-workflow-designer`: workflow recipe design, explicit edge handles, and correct text/image/video/voice port routing.
- `veogenie-model-selector`: choose image/video models, provider, resolution, aspect ratio, and duration for output nodes.
- `veogenie-image-to-video-input-planner`: decide when to generate an image before video, choose minimal video inputs, and omit redundant references that would confuse image/video models.
- `veogenie-continuity-asset-planner`: plan missing characters, wardrobe, props/products, locations, style refs, and voice inputs that must exist before video generation.
- `veogenie-viral-video-producer`: create hook-driven short-form scripts, natural dialogue, and ordered multi-scene video workflows.
- `veogenie-product-ad`: product image/video ad briefs, prompt standards, and product fidelity checks.
- `veogenie-video-director`: high-quality video prompt/script direction for Google Flow.
- `veogenie-result-qa`: optional output checking and export handoff when the user asks to inspect or save generated results.
- `veogenie-project-memory`: update the user's project memory files after explicit right/wrong feedback so future agents keep durable preferences and avoid repeated mistakes.

For workflow authoring, the agent should read the workflow designer port contract before writing canvas recipes. Voice input must use `voiceReference:voice -> videoGenerate:video-voice-reference`; if a human is connecting manually and the voice port is not visible, switch `Tao Video` to component/input view before connecting voice.

For prompt authoring, use `veogenie-ai-assistant-prompt-writer`. Codex should write the final prompt directly by default. Add `aiAssistant` / `Tro Ly AI` only when prompt generation must depend on runtime inputs, remain reusable on canvas, produce selectable variants, or the user explicitly wants an assistant prompt-writing stage.

Video image routing must follow user intent. If the user asks to make a video from frames or keyframes, use `frame-start` and optional `frame-end`, and do not also put those frame images into `video-reference-image`. If the user asks for synchronized voice or narration, put image inputs into `video-reference-image` by default and connect the voice to `video-voice-reference`; only use `frame-start`/`frame-end` when exact first/last frames are explicitly requested.

Model choice should follow `veogenie-model-selector`: GPT Image 2 for realistic images/storyboards, Nano Banana Pro or Nano Banana 2 at `2K`/`4K` for high-quality images, Omni Flash for the most realistic video, and Veo 3.1 models for normal video.

For image-first video workflows, use `veogenie-image-to-video-input-planner` before wiring `videoGenerate`. Fashion video should usually generate the final fashion still/look first, then pass only the useful anchor image and necessary identity refs into the video node. If the generated fashion image already contains the outfit clearly, omit separate clothing/wardrobe refs from `videoGenerate`.

For multi-scene videos, use `veogenie-continuity-asset-planner` before running `videoGenerate` nodes when the script has missing or recurring characters, products, props, wardrobe, locations, or style references. If the user supplies only one main character but the script adds other important characters, the agent should create those character reference images first, then route the finished assets to each relevant scene through `video-reference-image`.

For viral-style short videos, use `veogenie-viral-video-producer` to write the hook, beat sheet, natural dialogue, scene plan, and ordered `videoGenerate` clip workflow. When the user wants one final combined file, connect the finished scene clips into a `videoMerge` node with `videoGenerate:video -> videoMerge:video`, run it after the source clips succeed, and report/export the merge node result.

## Optional Guards

The default plugin has no workflow write/run permissions. For normal Codex chat usage, prefer temporary session permissions instead of asking the user to set PowerShell environment variables.

When the user explicitly approves an action in chat, Codex can call:

```json
{
  "permissions": ["canvas_write", "media_import", "actions"],
  "confirmGrantSessionPermissions": true,
  "approvalNote": "User approved creating a page, importing one local product image, and running image nodes."
}
```

with `grant_mcp_session_permissions`. Session permissions only apply to the current MCP server process, expire automatically, and disappear when Codex/plugin restarts. `run_workflow_payload` cannot be enabled this way and still requires `VEOGENIE_MCP_ALLOW_RUN=1`.

Available session permissions:

- `canvas_write`
- `media_import`
- `actions`
- `media_export`
- `project_export`

For persistent admin-managed access, add these environment variables only when you intentionally want Codex to perform the corresponding action:

```json
{
  "VEOGENIE_MCP_ALLOW_CANVAS_WRITE": "1"
}
```

```json
{
  "VEOGENIE_MCP_ALLOW_ACTIONS": "1"
}
```

```json
{
  "VEOGENIE_MCP_ALLOW_MEDIA_EXPORT": "1"
}
```

```json
{
  "VEOGENIE_MCP_ALLOW_MEDIA_IMPORT": "1"
}
```

```json
{
  "VEOGENIE_MCP_ALLOW_PROJECT_EXPORT": "1"
}
```

```json
{
  "VEOGENIE_MCP_ALLOW_RUN": "1"
}
```

Do not enable all guards by default.

`build_product_ad_workflow_recipe` is read-only. It only returns a suggested workflow recipe and next steps for a product ad job; it does not modify the canvas, import media, run automation, or export files.

`plan_product_ad_job` is read-only. It returns an end-to-end tool-call plan for a product ad job, including the recipe, node ids, required guards, polling rules, and optional render export steps; it does not execute those steps.

`get_run_orchestration_status` is read-only. Use it after a guarded `run_node` or `run_group` call to check command ack and sanitized output status before deciding whether to poll again.

`VEOGENIE_MCP_ALLOW_CANVAS_WRITE=1` or session permission `canvas_write` enables guarded canvas writes. `create_workflow_page` creates a new page, `append_workflow_to_current_page` appends a recipe, `update_workflow_nodes` edits schema-safe fields on existing nodes, `delete_workflow_nodes` removes existing nodes and connected edges, and `undo_last_mcp_canvas_write` rolls back the latest MCP canvas write when the token still matches. Node update/delete tools require `confirmModifyCurrentPage=true` and do not run Google Flow, ChatGPT, GPT Image 2, or raw `/workflow/run`.

`VEOGENIE_MCP_ALLOW_MEDIA_IMPORT=1` enables `attach_local_media_to_node`, which reads a local image path through the desktop app and attaches it to an existing `imageReference` node. It also enables `attach_chat_image_to_node` for user images from the AI Agent chat after the agent has staged the attachment as a local file under `workspaceRoot`. These tools still require their confirm flags and do not accept or return media bytes/base64/data URLs/blob URLs through MCP.

`VEOGENIE_MCP_ALLOW_PROJECT_EXPORT=1` enables `export_media_to_workspace`, which writes generated media into `<workspaceRoot>/render/`. The tool still requires `confirmWriteProjectRender=true`, an absolute `workspaceRoot`, and a media id from `get_media_album`; it does not accept media URLs/base64 through MCP and does not overwrite existing files unless `confirmOverwrite=true`.

## Reporting Results

VeoGenie results must be reported from the app state, not from a new image generated in Codex chat. After running a node or group, Codex should read `get_node_outputs`, then call `get_media_album` with the exact output `nodeId`, `source="generated"`, and the expected media `type`.

If the user wants files back in the project, Codex should export each verified `mediaId` with `export_media_to_workspace` after `project_export` is enabled, then report the exported file paths. MCP intentionally does not return media URLs or raw media payloads, so Codex should not display a separate generated preview as the VeoGenie output.

When the user asks Codex to judge whether a result matches the original brief, Codex can use the result QA skill as an optional helper. Keep the report practical: say which app media ids were checked, what was exported, and what looked right or wrong when local inspection is available.

## Project Memory From Feedback

After a VeoGenie task, Codex should not rely on chat history alone for durable user preferences. When the user explicitly says a result, prompt, workflow, or design was right or wrong and asks to remember or apply it next time, use the `veogenie-project-memory` skill.

Project memory updates should target the user's project, not the VeoGenie plugin repository:

- `AGENTS.md` for agent process and workflow rules.
- `CLAUDE.md` for short companion guidance.
- `DESIGN.md` for visual style, brand direction, prompt style, and approved/rejected looks.
- `BUSINESS_RULES.md` for durable domain rules, constraints, and mistakes that must not repeat.

Do not update these files silently after every run. Ask when feedback is ambiguous, preserve existing content, keep entries concise, avoid raw media/base64/private data, and report exactly which files changed.

## Agent Instructions

This marketplace also includes repo-level instructions for agents:

```text
AGENTS.md
CLAUDE.md
```

These files are lightweight usage guides for Codex, Claude, and other repo-aware agents. They explain node roles, correct input routing, shared voice wiring for multiple video nodes, and the basic MCP workflow. They are exported to the marketplace root and also kept inside `plugins/veogenie`.

## Export From App Repo

When this plugin lives inside the app repo, export a clean public-copy folder with:

```powershell
npm run plugin:export
```

The generated folder is:

```text
dist/codex-plugin/veogenie
```

Use this when you already have another Codex marketplace repo and only need to copy the plugin folder into `plugins/veogenie`.

For the Codex "Add marketplace" window, use the generated standalone marketplace folder:

```text
dist/codex-marketplace
```

That folder contains only:

```text
.agents/plugins/marketplace.json
AGENTS.md
CLAUDE.md
plugins/veogenie
```

The plugin folder contains:

```text
.codex-plugin/plugin.json
.mcp.json
bin/veogenie-mcp-launcher.cmd
AGENTS.md
CLAUDE.md
README.md
PUBLICATION_CHECKLIST.md
PRIVACY.md
TERMS.md
LICENSE.md
skills/veogenie/SKILL.md
skills/veogenie-ai-assistant-prompt-writer/SKILL.md
skills/veogenie-ai-assistant-prompt-writer/agents/openai.yaml
skills/veogenie-workflow-designer/SKILL.md
skills/veogenie-model-selector/SKILL.md
skills/veogenie-image-to-video-input-planner/SKILL.md
skills/veogenie-image-to-video-input-planner/references/minimal-video-input-routing.md
skills/veogenie-image-to-video-input-planner/references/image-first-patterns.md
skills/veogenie-continuity-asset-planner/SKILL.md
skills/veogenie-continuity-asset-planner/references/continuity-asset-manifest.md
skills/veogenie-continuity-asset-planner/references/preproduction-workflow-patterns.md
skills/veogenie-viral-video-producer/SKILL.md
skills/veogenie-viral-video-producer/references/viral-script-structures.md
skills/veogenie-viral-video-producer/references/natural-dialogue-rubric.md
skills/veogenie-viral-video-producer/references/multi-scene-workflow-patterns.md
skills/veogenie-product-ad/SKILL.md
skills/veogenie-video-director/SKILL.md
skills/veogenie-result-qa/SKILL.md
skills/veogenie-project-memory/SKILL.md
skills/veogenie-result-qa/references/semantic-result-qa.md
```

Point Codex Source to that folder, or copy that folder to a separate public repository. The plugin metadata now points to the verified public marketplace repository and local policy files:

```text
plugins/veogenie/PRIVACY.md
plugins/veogenie/TERMS.md
plugins/veogenie/LICENSE.md
```

Verified marketplace URL:

```text
https://github.com/nhattan658-coder/veogenie-codex-marketplace.git
```

For Codex "Add marketplace", use:

```text
Source: https://github.com/nhattan658-coder/veogenie-codex-marketplace.git
Git ref: main
Sparse paths: leave empty
```

If the marketplace appears but the VeoGenie plugin is not listed for install, enable it in `C:\Users\Admin\.codex\config.toml` and restart Codex:

```toml
[plugins."veogenie@veogenie-marketplace"]
enabled = true
```

See `PUBLICATION_CHECKLIST.md` for the full release checklist.

## Hermes Agent Offline Package

`npm run plugin:export` also creates a Hermes-friendly offline package:

```text
dist/hermes-agent
```

This folder is not a Codex marketplace. It is for MCP clients such as Hermes Agent that can read an MCP server config plus instruction/knowledge files.

The Hermes package contains:

```text
README-HERMES.md
HERMES_INSTRUCTIONS.md
mcp-config.json
mcp-config.absolute.example.json
bin/veogenie-mcp-launcher.cmd
skills/
LICENSE.md
PRIVACY.md
TERMS.md
VERSION.txt
```

For offline customer handoff, zip `dist/hermes-agent` as:

```text
veogenie-hermes-agent-<version>.zip
```

Customer setup summary:

1. Install and open VeoGenie Tool Agent.
2. Unzip the Hermes package to a stable folder, for example `C:\VeoGenie\veogenie-hermes-agent`.
3. Add `mcp-config.json` to Hermes Agent's MCP configuration.
4. Add `HERMES_INSTRUCTIONS.md` as Hermes project/system instructions.
5. Add the `skills/` folder as Hermes knowledge/instructions if Hermes supports folder attachments.
6. Restart Hermes Agent and run the smoke test from `README-HERMES.md`.

If Hermes does not resolve relative `cwd` from `mcp-config.json`, use `mcp-config.absolute.example.json` and replace the launcher path with the customer's unzip path.

## Test Prompt

```text
Use the VeoGenie MCP plugin to check the open desktop app:
1. Call get_mcp_capabilities.
2. Call get_app_status.
3. Call list_pages.
4. Call get_current_workflow and report the active page node/edge count.
5. Optionally read the workflow designer skill and confirm that voice input uses video-voice-reference.
6. Optionally call build_product_ad_workflow_recipe for a sample product brief and confirm it only returns a recipe.
7. Optionally read the project memory skill and explain when it should update AGENTS.md, CLAUDE.md, DESIGN.md, or BUSINESS_RULES.md.
Do not run Google Flow, ChatGPT, GPT Image 2, create/append pages, import media, export files, run_node, run_group, or run_workflow_payload.
```
