# VeoGenie Result Handoff Checklist

Use this checklist whenever reporting generated results.

## After Run

- `run_node` or `run_group` returned a `commandId`.
- `get_run_orchestration_status` was polled with that `commandId`.
- The final phase is `complete`, not `running`, `waiting_for_ui_ack`, or `waiting_for_output`.
- No output node reports `generationStatus="error"`.

## Node Output Check

Call:

```json
{
  "nodeId": "exact-output-node-id"
}
```

with `get_node_outputs`.

Confirm:

- The node id matches the node the user asked to run.
- The node type matches expected output: `imageGenerate`, `videoGenerate`, or `aiAssistant`.
- The output status is success.
- `generatedAsset` or `generatedText` exists when expected.

## Media Album Check

For images:

```json
{
  "nodeId": "exact-image-node-id",
  "source": "generated",
  "type": "image",
  "limit": 4
}
```

For videos:

```json
{
  "nodeId": "exact-video-node-id",
  "source": "generated",
  "type": "video",
  "limit": 4
}
```

Confirm:

- Returned items belong to the exact `nodeId`.
- Returned count matches expected `resultCount` or generated history count.
- Use only returned `mediaId` values for export.

## Export Check

For `export_media_to_workspace`:

- Use `mediaId` from node-specific `get_media_album`.
- Pass `pageId` if the album item includes it.
- Pass absolute `workspaceRoot`.
- Keep output under `render/`.
- Set `confirmWriteProjectRender=true`.
- Poll `get_command_status` until accepted or rejected.

If export rejects:

1. Refresh `get_current_workflow`.
2. Refresh `get_node_outputs(nodeId=...)`.
3. Refresh `get_media_album(nodeId=..., source="generated", type=...)`.
4. Retry export once.
5. If it still fails, report the exact rejection and leave the result in the app.

## Optional Semantic QA Export

When the user wants the agent to judge whether the result matches the original prompt or brief:

- First complete the technical checks above.
- Export candidates to `render/qa/<job-slug>/` with `export_media_to_workspace`.
- Use only the node-specific `mediaId` values from `get_media_album`.
- Poll `get_command_status` before inspecting or reporting any exported file.
- Read `semantic-result-qa.md` for the scoring rubric and one-retry rule.

If the local environment cannot inspect the exported media type, report that limit instead of claiming semantic visual verification.

## Never Do

- Do not search browser cache, `%LOCALAPPDATA%`, IndexedDB, app storage, or temp folders for generated media.
- Do not use raw media URL/base64 through MCP.
- Do not generate a new image/video in chat as a replacement result.
- Do not report exported files unless export command status confirms success.
