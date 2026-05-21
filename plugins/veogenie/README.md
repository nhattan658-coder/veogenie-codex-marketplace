# VeoGenie Codex Plugin

This plugin connects Codex to the locally installed VeoGenie desktop app through MCP.

## Requirements

1. Install VeoGenie Tool.
2. Open the desktop app.
3. Confirm the local backend is running:

```powershell
Invoke-RestMethod http://127.0.0.1:8788/health
```

The expected response is:

```json
{ "ok": true }
```

## MCP Launcher

The plugin expects the installed app to provide:

```text
D:\VeoGenie Tool\veogenie-mcp.cmd
```

The launcher starts the MCP server bundled with the desktop app and connects to:

```text
http://127.0.0.1:8788
```

## Default Permissions

The default `.mcp.json` is read-only. It lets Codex call tools such as:

- `get_mcp_capabilities`
- `get_app_status`
- `list_pages`
- `get_current_workflow`
- `get_node_outputs`
- `get_media_album`
- `build_product_ad_workflow_recipe`
- `plan_product_ad_job`
- `get_command_status`
- `get_run_orchestration_status`

## Optional Guards

The default plugin remains read-only. For normal Codex chat usage, prefer temporary session permissions instead of asking the user to set PowerShell environment variables.

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

`VEOGENIE_MCP_ALLOW_MEDIA_IMPORT=1` enables `attach_local_media_to_node`, which reads a local image path through the desktop app and attaches it to an existing `imageReference` node. The tool still requires `confirmImportLocalFile=true` and does not return media bytes/base64 through MCP.

`VEOGENIE_MCP_ALLOW_PROJECT_EXPORT=1` enables `export_media_to_workspace`, which writes generated media into `<workspaceRoot>/render/`. The tool still requires `confirmWriteProjectRender=true`, an absolute `workspaceRoot`, and a media id from `get_media_album`; it does not accept media URLs/base64 through MCP and does not overwrite existing files unless `confirmOverwrite=true`.

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
plugins/veogenie
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

## Test Prompt

```text
Use the VeoGenie MCP plugin to check the open desktop app:
1. Call get_mcp_capabilities.
2. Call get_app_status.
3. Call list_pages.
4. Call get_current_workflow and report the active page node/edge count.
5. Optionally call build_product_ad_workflow_recipe for a sample product brief and confirm it only returns a recipe.
Do not run Google Flow, ChatGPT, GPT Image 2, create/append pages, import media, export files, run_node, run_group, or run_workflow_payload.
```
