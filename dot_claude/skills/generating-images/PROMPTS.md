# Image Generation Prompt Guide

Detailed guide for crafting effective prompts with Gemini image generation.

## Core Principle

**"Describe the scene, don't just list keywords."**

The model excels at understanding narrative descriptions. Detailed, story-like prompts produce far better results than disconnected keywords.

```
❌ Bad:  "hero image, blue, tech, modern, gradient"
✓ Good: "A modern hero image for a tech startup landing page, featuring
         flowing abstract 3D waves in electric blue and cyan gradients,
         with soft ambient lighting creating a futuristic atmosphere"
```

## Prompt Structure Template

```
A [style/type] [image/photo/illustration] of [subject],
[action/state/composition], set in/on [environment/background].
The [lighting type] creates [mood/atmosphere].
[Additional technical details if needed].
```

## Category-Specific Guidelines

### Photorealistic Images

Include photography terminology for best results:

**Camera & Lens:**
- Shot types: "close-up", "wide shot", "aerial view", "eye-level"
- Lens: "85mm portrait lens", "50mm standard", "24mm wide-angle"
- Focus: "shallow depth of field", "sharp focus", "bokeh background"

**Lighting:**
- Natural: "golden hour sunlight", "overcast soft light", "harsh midday sun"
- Studio: "three-point lighting", "softbox setup", "rim lighting"
- Mood: "dramatic shadows", "high-key bright", "low-key moody"

**Example:**
```
A professional headshot photograph of a confident business person,
shot with an 85mm lens at f/2.8 for shallow depth of field.
Three-point studio lighting with a soft key light creates
a warm, approachable atmosphere. Clean gray background.
```

### Illustrations & Icons

Be explicit about artistic style:

**Style descriptors:**
- "flat design", "isometric", "3D rendered", "hand-drawn sketch"
- "kawaii", "minimalist", "cel-shading", "watercolor style"
- "vector art", "pixel art", "line art", "geometric"

**Technical details:**
- "bold outlines", "no outlines", "soft gradients"
- "limited color palette", "monochromatic", "vibrant colors"
- "transparent background", "solid color background"

**Example:**
```
A minimalist flat design icon of a rocket ship,
using a limited palette of blue and orange,
bold outlines with no gradients, suitable for app icon.
Transparent background, centered composition.
```

### Product Photography

Structure for commercial-quality results:

**Template:**
```
Professional product photography of [product with materials],
placed on [surface/background], lit with [lighting setup]
to [highlight specific feature]. Shot from [angle] with
focus on [detail]. [Quality descriptor].
```

**Example:**
```
Professional product photography of a sleek matte black
wireless headphone on a white marble surface.
Soft diffused lighting from the left highlights the
premium texture. Shot from 45-degree angle with focus
on the ear cup detail. Commercial catalog quality.
```

### Text & Logo Design

For images containing text (use Pro model recommended):

**Best practices:**
- Specify font style descriptively: "clean bold sans-serif", "elegant script"
- Clarify placement: "centered", "bottom-right corner"
- Include design concept: "modern tech company", "luxury brand"

**Example:**
```
A modern logo design for a tech startup called "Nova",
featuring clean bold sans-serif typography with the word
in dark blue. Accompanied by an abstract geometric star
symbol. Minimalist design on white background,
suitable for web and print.
```

### Backgrounds & Textures

For web backgrounds and UI elements:

**Template:**
```
A [adjective] [pattern type] background in [color] tones,
[seamless/gradient/textured], suitable for [use case].
[Mood descriptor], non-distracting.
```

**Example:**
```
A subtle seamless geometric pattern background in
soft purple and blue gradient tones, suitable for
SaaS dashboard UI. Modern and professional feel,
non-distracting with low contrast.
```

### Hero Images / Marketing

For landing pages and marketing materials:

**Key elements to include:**
- Purpose: "landing page", "banner", "social media"
- Mood: "inspiring", "professional", "playful"
- Visual elements: specific objects, abstract concepts
- Color scheme: specific colors or palette type

**Example:**
```
A stunning hero image for a fintech startup landing page,
featuring abstract flowing lines representing data streams
in gold and dark blue colors. Soft gradient background
transitioning from dark navy to lighter blue.
Professional, trustworthy, and modern aesthetic.
16:9 aspect ratio, high-end commercial quality.
```

## Quality Enhancement Tips

### Adding Detail
- Specify materials: "brushed aluminum", "matte plastic", "velvet fabric"
- Include texture: "smooth", "rough", "glossy", "weathered"
- Mention quality: "8K quality", "high resolution", "commercial grade"

### Controlling Composition
- Use placement terms: "centered", "rule of thirds", "negative space on left"
- Specify framing: "full frame", "cropped tight", "with breathing room"

### Setting Mood
- Atmosphere: "cozy", "energetic", "calm", "dramatic"
- Time/season: "autumn afternoon", "summer morning", "twilight"
- Feeling: "nostalgic", "futuristic", "organic", "technical"

## Common Mistakes to Avoid

1. **Keyword dumping**: "blue modern tech gradient abstract hero"
   → Use complete sentences describing the scene

2. **Vague descriptions**: "a nice image for my website"
   → Be specific about style, colors, and composition

3. **Conflicting instructions**: "minimalist with lots of detail"
   → Keep style consistent throughout

4. **Missing context**: "a logo"
   → Include: for what, what style, what colors, what mood

5. **Overcomplicating**: Too many elements competing for attention
   → Focus on 2-3 key visual elements

## Iterative Refinement

If the first result isn't satisfactory:

1. **Add specificity**: Include more details about what you want
2. **Adjust style**: Try different style descriptors
3. **Change perspective**: Specify different camera angle or composition
4. **Modify lighting**: Adjust lighting description for different mood
5. **Switch to Pro model**: For complex scenes or fine details

## Quick Reference: Style Keywords

| Category | Keywords |
|----------|----------|
| **Photo styles** | editorial, documentary, portrait, product, lifestyle |
| **Art styles** | minimalist, maximalist, abstract, geometric, organic |
| **Rendering** | 3D render, vector, flat design, isometric, realistic |
| **Mood** | professional, playful, elegant, bold, subtle |
| **Lighting** | soft, dramatic, natural, studio, neon, ambient |
| **Colors** | monochromatic, vibrant, pastel, earth tones, gradient |
