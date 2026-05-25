# Product Ad Rubric

## Prompt Templates

Use this structure and adapt it to the product. Keep product identity stricter than style.

```text
Create a high-end photorealistic product advertising image for [product].
Keep the exact product identity: [packaging, logo, color, shape, label details].
Scene: [environment, surface, props, background].
Composition: [camera angle, framing, focal length feel, product placement, safe crop].
Lighting: [soft studio, dramatic rim light, daylight, glossy reflections, contact shadows].
Mood: [premium, fresh, clinical, energetic, natural, luxury].
Material details: [glass, metal, plastic, paper, liquid, fabric, skin-care texture].
Constraints: no extra text, no altered logo, no distorted packaging, no extra products, no watermark.
```

For product video, use a single clear motion idea:

```text
Create a photorealistic premium product advertising video for [product], [aspect ratio], [duration expectation].
Keep the exact product identity from the reference: [packaging, logo, color, shape, label details].
Scene: [specific set, surface, props, background].
Action: [single beginning, middle, end, such as reveal, hand use, pour, spray, turntable, macro detail].
Camera: [framing, lens feel, slow push, orbit, handheld phone, or tripod].
Lighting: [realistic source, reflections, shadows, material highlights].
Motion: [believable product, hand, liquid, steam, fabric, or environmental motion].
Constraints: product stays readable and primary for the whole clip, no extra text, no altered logo, no warped packaging, no duplicate products, no watermark.
```

## Photorealistic Product Rules

- Describe physical materials and how light hits them, not just "beautiful" or "premium".
- Keep the product large enough to inspect in the final crop.
- Use believable props that match the category; avoid props that hide, duplicate, or compete with the product.
- Preserve label/logo placement and distinctive packaging geometry even when changing background or lighting.
- For human hand or model interaction, specify natural hand placement, realistic skin texture, and no distorted fingers.
- For liquids, food, cosmetics, glass, metal, or glossy packaging, name reflections, droplets, condensation, powder, foam, or texture only when relevant.

## Shot Styles

- Clean ecommerce hero: white or neutral background, soft shadow, accurate product color.
- Premium studio: dark or neutral set, controlled reflections, rim light, high contrast.
- Lifestyle context: product in a believable usage environment with restrained props.
- Ingredient/material macro: close-up texture, droplets, powder, fabric, metal, glass, or surface detail.
- Social launch ad: bold composition, clear product silhouette, fast-readable visual hierarchy.

## Quality Bar

Accept a result only when:

- The product is recognizable and not replaced by a generic object.
- Packaging and label placement are not visibly corrupted.
- The product remains the primary subject.
- Props support the product and do not compete with it.
- Lighting matches the material: glass, metal, plastic, paper, fabric, liquid, or skin-care surfaces.
- The crop leaves enough safe area for platform use.
- The image/video looks physically plausible: consistent shadows, reflections, scale, and perspective.
- Video keeps the product visible through most of the clip and does not trade fidelity for motion.

## Common Failure Modes

- Product logo changes or becomes unreadable.
- Model invents extra products, duplicate packaging, or fake text.
- Background is attractive but product is too small.
- Video motion hides the product for most of the clip.
- Prompt asks for too many campaign ideas in one output.
- Over-stylized render makes the product look like CGI when the brief asked for photorealism.
- Hands, faces, liquid, or packaging edges become distorted because the prompt asked for too much action.

## Variant Strategy

For `resultCount > 1`, vary one dimension at a time:

- Background: studio, lifestyle, macro set.
- Lighting: soft daylight, premium rim light, glossy commercial.
- Composition: centered hero, low-angle hero, close-up detail.

Do not vary the product identity between variants.

## Pre-Handoff QA Checklist

Before running or handing off a prompt:

- The prompt states the exact product details that must not change.
- The shot has one primary composition and one primary motion idea for video.
- Camera, lighting, material, and crop are concrete enough for a high-quality realistic output.
- Forbidden outputs are explicit: no extra text, fake logos, duplicate products, watermarks, or warped packaging.
- The QA plan will verify results from VeoGenie app media ids, not chat-generated substitute media.
