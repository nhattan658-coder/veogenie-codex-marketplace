# VeoGenie Voice Connection Rules

Use this file whenever a workflow includes a `voiceReference` node or a user asks for voice/narration/speaker control.

## Graph Contract

The only valid voice connection into a generate node is:

```json
{
  "source": "voice-1",
  "target": "video-1",
  "sourceHandle": "voice",
  "targetHandle": "video-voice-reference"
}
```

`voiceReference` is for `videoGenerate`. Do not connect it to `imageGenerate`.

## UI Component Mode

When a human or UI agent is dragging connections on the canvas:

- The `Tao Video` node may need to show its component/input ports before voice can be connected.
- If the voice port is not visible, switch the video node into the component/input view first.
- Do not connect the voice node to a different visible port as a fallback.
- The visible voice port maps to `video-voice-reference`.

When using MCP recipes:

- The UI visibility mode is not the contract.
- Still create the edge with `sourceHandle="voice"` and `targetHandle="video-voice-reference"`.
- The app validates handles before writing the recipe.

## Preset Voices

Preset voices already listed in the `Giong Noi` node, such as Gemini/Flow preset names, should be connected as `voiceReference`.

Current automation behavior:

- Preset voices are sent as a video prompt hint because the current Flow picker may not render a usable `Giong noi` tab for those presets.
- The backend logs this path as `voice-preset-prompt-hint`.
- The graph edge is still `voiceReference:voice -> videoGenerate:video-voice-reference`.

## Custom Or Saved Flow Voices

Custom or saved Flow voices use the picker path:

1. Open the composer component picker.
2. Select the `Giong noi` / voice tab.
3. Select the matching saved voice.
4. Click `Them vao cau lenh` if Flow requires it.
5. Verify the composer has the voice before `Generate`.

If the custom voice cannot be found or verified, stop and report the error. Do not submit video without the custom voice.

## Multiplicity

Use at most one effective `voiceReference` edge per `videoGenerate` node.

If the user provides multiple desired voices:

- Ask for the primary voice, or
- Create separate video branches, one voice per `videoGenerate`.

## Voice Recipe Example

```json
{
  "nodes": [
    {
      "id": "voice-achernar",
      "type": "voiceReference",
      "title": "Voice",
      "voiceName": "Achernar",
      "voiceDescription": "soft, clear female voice",
      "position": { "x": 80, "y": 520 }
    },
    {
      "id": "video-ad",
      "type": "videoGenerate",
      "title": "Generate video",
      "model": "veo-3.1-lite",
      "aspectRatio": "9:16",
      "duration": 8,
      "position": { "x": 760, "y": 260 }
    }
  ],
  "edges": [
    {
      "id": "voice-to-video",
      "source": "voice-achernar",
      "target": "video-ad",
      "sourceHandle": "voice",
      "targetHandle": "video-voice-reference"
    }
  ]
}
```
