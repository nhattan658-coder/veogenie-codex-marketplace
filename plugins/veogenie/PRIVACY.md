# VeoGenie Codex Plugin Privacy

The VeoGenie Codex plugin connects Codex to the locally installed VeoGenie desktop app through a plugin-bundled launcher resolver. The resolver finds the installed `veogenie-mcp.cmd` without assuming a fixed install drive.

By default, the plugin has no workflow write/run permissions and reads sanitized workflow state from the local backend at `http://127.0.0.1:8788`. Read-only tools do not return raw media URLs, data URLs, base64 payloads, license issuer data, private keys, or customer source files.

If the user asks the agent to control VeoGenie and the backend is not reachable, `open_installed_app` can launch the locally installed desktop app after `confirmOpenApp=true`. It does not close/restart the app, run workflows, or access media payloads.

If the user asks the agent to prepare Google Flow access, `open_google_flow_login` can ask the open desktop app to launch the local managed Chrome/Edge debug browser after `confirmOpenGoogleFlowLogin=true`. It does not run workflows, click Generate, or access media payloads.

Optional write, run, media import, and export tools are disabled unless the user explicitly enables the matching MCP guard environment variable or grants temporary session permission in chat. When enabled, those tools still require tool-specific confirm fields and are executed by the local desktop app.

The plugin does not send workflow data to the plugin repository owner. Any Google Flow or ChatGPT browser automation is performed by the installed desktop app in the user's own browser session only when the user enables the relevant guarded action.

For support, use the public repository issues page:

```text
https://github.com/nhattan658-coder/veogenie-codex-marketplace/issues
```
