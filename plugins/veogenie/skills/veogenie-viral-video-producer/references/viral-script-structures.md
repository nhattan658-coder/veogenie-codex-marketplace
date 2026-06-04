# Viral Short Video Script Structures

Use these structures to build a short-form video beat sheet. They improve retention but do not guarantee virality.

## Default Viral Structure

For a 20-45 second short:

1. Hook, `0-2s`: stop the scroll with tension, curiosity, proof, or a surprising visual.
2. Setup, `2-6s`: make the viewer understand the situation, desire, problem, or promise.
3. Escalation, `6-15s`: show the obstacle, mistake, demo, transformation, proof, or rising stakes.
4. Payoff, `15-30s`: reveal the result, twist, benefit, lesson, or emotional moment.
5. CTA or loop ending, final `2-5s`: tell the viewer what to do, or end in a way that loops naturally back to the hook.

For 45-90 seconds, repeat escalation/proof beats instead of making the intro longer.

## Hook Types

Choose one clear hook, not several at once:

- Consequence: "Neu ban lam buoc nay sai, ca video se hong."
- Curiosity gap: "Co mot chi tiet nho lam canh nay tu gia thanh that."
- Proof first: show the final result, then explain how it happened.
- Contradiction: "Dung dung anh nay lam frame dau neu ban muon video co giong noi."
- Problem callout: "Video AI nghe gia vi loi thoai qua sach se."
- POV: "POV: khach hang thay san pham cua ban lan dau."
- Before/after: start with the bad version, then reveal the fixed version.
- Urgency: "Ban chi co 2 giay dau de giu nguoi xem."

Avoid:

- "Xin chao moi nguoi..."
- "Trong video nay toi se..."
- Long brand/logo openings.
- Abstract claims without a concrete visual.

## Common Structures

### Problem -> Mistake -> Fix -> Result

Best for tutorials, workflow tips, product demos, and AI-video education.

Scene plan:

- `scene-01-hook`: show the mistake/result gap.
- `scene-02-problem`: explain what is going wrong.
- `scene-03-fix`: show the key change.
- `scene-04-proof`: show the improved output.
- `scene-05-cta`: invite viewer to try or save.

### Desire -> Obstacle -> Transformation -> Payoff

Best for lifestyle, beauty, product, and story videos.

Scene plan:

- `scene-01-hook`: show the desired outcome or emotional tension.
- `scene-02-obstacle`: show why it is hard.
- `scene-03-action`: show the attempt/process.
- `scene-04-transformation`: reveal the change.
- `scene-05-payoff`: emotional result or product benefit.

### UGC Ad

Best for product ad workflows.

Scene plan:

- `scene-01-hook`: creator says the problem or surprising result.
- `scene-02-context`: show product in a natural setting.
- `scene-03-demo`: one clear use case.
- `scene-04-proof`: close-up benefit or result.
- `scene-05-cta`: simple next step.

## Beat Sheet Format

Return scenes in this shape:

```json
{
  "sceneId": "scene-01-hook",
  "duration": 6,
  "purpose": "hook",
  "viewerQuestion": "Why does this look so real?",
  "visualAction": "A creator holds up two AI video clips, one fake-looking and one natural.",
  "spokenLine": "Nhin canh ben trai di. No bi lo la AI chi vi mot cau noi.",
  "transition": "Cut to the fake clip close-up.",
  "suggestedNodeIds": {
    "textPrompt": "prompt-scene-01",
    "videoGenerate": "video-scene-01"
  }
}
```

Each scene needs one clear job. If a scene does not create curiosity, proof, emotion, or action, remove it.
