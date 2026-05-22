# VeoGenie Semantic Result QA

Use this reference when the user asks the agent to judge whether generated image or video results match the original request before final handoff.

## QA Contract

- Keep the original user brief as the judging source. Do not judge only against the final generated prompt if it lost user constraints.
- Use VeoGenie app state as the source of truth for which results exist.
- Use only `mediaId` values returned by node-specific `get_media_album`.
- For visual inspection, export the candidate media with `export_media_to_workspace` into a QA subfolder under `render/`, such as `render/qa/<job-slug>/`.
- Do not use browser cache, app storage, IndexedDB, temp folders, media URLs, data URLs, blob URLs, or base64.
- Do not create a separate chat-generated image or video as a replacement result.

## Sequence

1. Write a short `originalBrief` checklist before running or before judging:
   - goal
   - required subject, product, or identity
   - required scene, action, style, aspect ratio, duration, and language
   - required voice or spoken line
   - forbidden changes, artifacts, logos, watermarks, or text
2. Run the normal technical handoff checklist in `result-handoff-checklist.md`.
3. If semantic QA is requested and `project_export` is available, export each candidate `mediaId` to `render/qa/<job-slug>/`.
4. Poll `get_command_status` for each export command.
5. Inspect the exported files when the local environment supports that media type.
6. Score each candidate as `pass`, `partial`, or `fail`.
7. If at least one candidate passes and the user did not require every result to pass, select the best passing candidate and do not retry.
8. If no candidate passes, retry the same node or group at most once with a targeted correction prompt.
9. After the retry, repeat technical handoff and semantic QA once. Report the best verified candidate or report failure.

## Visual Inspection Limits

Images can usually be inspected after export as local files. Videos may require frame extraction or another available local viewer/tool. If the environment cannot inspect a video visually, report that semantic visual QA was not available and do not pretend it was verified.

Metadata-only checks can confirm node id, media type, count, and export status. They cannot prove that an image or video visually matches the brief.

## Rubric

Judge each exported candidate with:

- `promptAlignment`: matches the original user brief and final prompt direction.
- `requiredElements`: includes required product, subject, scene, action, language, and count.
- `identityConsistency`: preserves required face, character, product shape, brand cues, and key visual identity.
- `styleAndComposition`: matches requested mood, framing, aspect ratio, camera direction, and quality level.
- `technicalQuality`: no broken render, severe blur, obvious distortion, unreadable key subject, black frame, or corrupted export.
- `forbiddenElements`: no unwanted watermark, logo, text, extra character, wrong language, or prohibited transformation.

Mark `pass` only when all critical constraints are satisfied. Mark `partial` when the result is usable but has non-critical drift. Mark `fail` when a critical requirement is missing or contradicted.

## One Retry Rule

Retry only when:

- technical run/export is complete enough to identify a real failed result, or
- semantic QA finds a clear mismatch with the original brief.

Before retry:

- Ensure no command is still `queued`, `dispatched`, or running.
- Ensure `actions` permission is enabled.
- Preserve the original brief and working constraints.
- Add only targeted correction instructions for the observed failure.

Do not retry more than once for the same user request unless the user explicitly approves another run.

## Retry Prompt Pattern

Use this structure for the correction prompt or assistant instruction:

```text
Retry once. Preserve: <critical subject/product/identity/style>.
Fix these failures from the previous result: <specific observed failures>.
Keep these original requirements: <aspect/duration/language/voice/required action>.
Avoid: <forbidden artifacts or previous errors>.
```

## Final Handoff Fields

Include these fields in the final report when semantic QA was used:

- `qaStatus`: `pass`, `retry_pass`, `partial`, or `fail`
- `retryAttempted`: `true` or `false`
- `selectedMediaId`
- `qaExportPath` when a QA export succeeded
- `qaReasons`
- `unverifiedLimits` when the environment could not inspect video or another media type
