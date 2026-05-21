# VeoGenie Codex Plugin Privacy

The VeoGenie Codex plugin connects Codex to the locally installed VeoGenie desktop app through the bundled MCP launcher at `D:\VeoGenie Tool\veogenie-mcp.cmd`.

By default, the plugin only reads sanitized workflow state from the local backend at `http://127.0.0.1:8788`. Read-only tools do not return raw media URLs, data URLs, base64 payloads, license issuer data, private keys, or customer source files.

Optional write, run, media import, and export tools are disabled unless the user explicitly enables the matching MCP guard environment variable. When enabled, those tools still require tool-specific confirm fields and are executed by the local desktop app.

The plugin does not send workflow data to the plugin repository owner. Any Google Flow or ChatGPT browser automation is performed by the installed desktop app in the user's own browser session only when the user enables the relevant guarded action.

For support, use the public repository issues page:

```text
https://github.com/nhattan658-coder/veogenie-codex-marketplace/issues
```
