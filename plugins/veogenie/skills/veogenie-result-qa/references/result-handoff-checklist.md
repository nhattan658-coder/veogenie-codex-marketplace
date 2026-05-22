# Result Handoff Checklist

## Before Saying Complete

Confirm:

- Page name or page id is known.
- Output node id is known.
- Output node status is `success`.
- `get_media_album` was filtered by exact `nodeId`.
- Album filter used `source="generated"`.
- Album filter used the expected media type.
- Returned count matches expected `resultCount` or node history.
- No media raw payload was requested or exposed.

## Export Checklist

For each generated media item:

1. Use the `mediaId` returned by node-specific `get_media_album`.
2. Use `export_media_to_workspace` only with project export permission and `confirmWriteProjectRender=true`.
3. Keep output inside `<workspaceRoot>/render/`.
4. Use safe, stable filenames.
5. Avoid overwrite unless the user explicitly approved it.
6. Poll `get_command_status` after export.

## Final Report Fields

Include:

- Page name or page id.
- Output node id.
- Verified media count.
- Media ids used for export.
- Exported file paths when export succeeds.
- Rejected command message when export fails.

Do not include a fake preview image or external generated asset.
