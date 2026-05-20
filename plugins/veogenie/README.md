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
- `get_command_status`

## Optional Guards

Only add these environment variables when you intentionally want Codex to perform the corresponding action:

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
  "VEOGENIE_MCP_ALLOW_RUN": "1"
}
```

Do not enable all guards by default.

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

Point Codex Source to that folder, or copy that folder to a separate public repository. The default metadata is valid for local testing; before publishing, replace the `example.com` URLs and contact details in `.codex-plugin/plugin.json` with real publisher, repository, privacy, and terms URLs.

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
Do not run Google Flow, ChatGPT, GPT Image 2, run_node, run_group, or run_workflow_payload.
```
