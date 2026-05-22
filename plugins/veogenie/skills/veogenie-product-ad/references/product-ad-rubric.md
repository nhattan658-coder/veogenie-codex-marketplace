# Product Ad Rubric

## Prompt Template

Use this structure and adapt it to the product:

```text
Create a high-end product advertising image/video for [product].
Keep the exact product identity: [packaging, logo, color, shape, label details].
Scene: [environment, surface, props, background].
Composition: [camera angle, framing, focal length feel, product placement].
Lighting: [soft studio, dramatic rim light, daylight, glossy reflections].
Mood: [premium, fresh, clinical, energetic, natural, luxury].
Action or motion: [only for video].
Constraints: no extra text, no altered logo, no distorted packaging, no extra products.
```

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

## Common Failure Modes

- Product logo changes or becomes unreadable.
- Model invents extra products, duplicate packaging, or fake text.
- Background is attractive but product is too small.
- Video motion hides the product for most of the clip.
- Prompt asks for too many campaign ideas in one output.

## Variant Strategy

For `resultCount > 1`, vary one dimension at a time:

- Background: studio, lifestyle, macro set.
- Lighting: soft daylight, premium rim light, glossy commercial.
- Composition: centered hero, low-angle hero, close-up detail.

Do not vary the product identity between variants.
