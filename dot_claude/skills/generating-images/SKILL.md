---
name: generating-images
description: Gemini APIを使用して画像を生成し、リポジトリに保存。ランディングページ、ヒーローイメージ、プロダクト画像、アバター、ダミー画像、プレースホルダー画像が必要なときに使用。画像生成、AI画像、自動生成。
---

# Generating Images

Generate images using Gemini API and save them to the repository.

## Quick Start

```bash
# Set API key
export GEMINI_API_KEY="your-api-key"

# Generate an image (uses flash model by default)
python ~/.claude/skills/generating-images/scripts/generate_image.py \
  --prompt "A modern minimalist hero image for a tech startup" \
  --output "./assets/images/hero.png"
```

## Key Concepts

### Models

| Model | ID | Use Case |
|-------|-----|----------|
| **flash** (default) | `gemini-2.5-flash-image` | Fast, lightweight. Good for drafts and iterations |
| **pro** | `gemini-3-pro-image-preview` | High quality. Use for final production images |

### Other Settings
- **Output**: PNG format
- **Aspect ratios**: `1:1`, `16:9`, `9:16`, `4:3`, `3:4`, `3:2`, `2:3`
- **API Key**: Environment variable `GEMINI_API_KEY`

## Workflows

### Workflow 1: Basic Generation (Start with Flash)

1. Understand user's image requirements (purpose, style, colors)
2. Craft an effective prompt using guidelines below
3. Generate with **flash** model first (fast iteration)
4. Show result to user

```bash
python ~/.claude/skills/generating-images/scripts/generate_image.py \
  --prompt "Your descriptive prompt here" \
  --output "./path/to/image.png" \
  --aspect-ratio "16:9"
```

### Workflow 2: Quality Upgrade (Switch to Pro)

If user requests regeneration or higher quality:

```bash
python ~/.claude/skills/generating-images/scripts/generate_image.py \
  --prompt "Your descriptive prompt here" \
  --output "./path/to/image.png" \
  --quality pro
```

**When to switch to Pro:**
- User says "make it better", "higher quality", "more detailed"
- After 2+ regeneration attempts with flash
- For final production images
- When fine details matter (text, faces, complex scenes)

### Workflow 3: Edit with Reference Image

Use an existing image as a starting point:

```bash
python ~/.claude/skills/generating-images/scripts/generate_image.py \
  --prompt "Add a gradient overlay and modern typography" \
  --input "./reference.png" \
  --output "./assets/hero-with-text.png"
```

### Workflow 4: Iterative Refinement

1. **First attempt**: Flash model with initial prompt
2. **If unsatisfied**: Refine prompt, try flash again
3. **If still unsatisfied**: Switch to pro model
4. **Final output**: Save to appropriate location

## Prompt Guidelines

**Core principle: "Describe the scene, don't just list keywords."**

```
❌ Bad:  "hero image, blue, tech, modern"
✓ Good: "A modern hero image for a tech startup, featuring flowing
         abstract 3D waves in electric blue gradients with soft lighting"
```

### Prompt Structure

```
A [style] [type] of [subject], [action/state], set in [environment].
The [lighting] creates [mood]. [Technical details].
```

### Quick Templates

| Use Case | Template |
|----------|----------|
| Hero Image | "A [mood] hero image for [purpose], featuring [elements] in [colors], [lighting], [quality]" |
| Product | "Professional product photography of [product] on [background], [lighting], [angle]" |
| Icon | "A [style] icon of [subject], [colors], [background type]" |
| Background | "A subtle [pattern] background in [colors], suitable for [use], non-distracting" |

### Key Techniques

**For photorealism**: Use photography terms
- "85mm lens", "shallow depth of field", "three-point lighting", "golden hour"

**For illustrations**: Specify style explicitly
- "flat design", "minimalist", "3D rendered", "vector art", "isometric"

**For quality**: Add descriptors
- "commercial quality", "8K resolution", "professional", "high-end"

**Detailed prompt guide**: See [PROMPTS.md](PROMPTS.md) for comprehensive examples and techniques.

## Configuration

### Environment Variable

| Variable | Required | Description |
|----------|----------|-------------|
| `GEMINI_API_KEY` | Yes | Google Gemini API key |

### Script Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `--prompt` | string | required | Image generation prompt |
| `--output` | string | required | Output file path (.png) |
| `--input` | string | - | Reference image for editing |
| `--aspect-ratio` | string | `1:1` | Image aspect ratio |
| `--quality` | string | `flash` | Model: `flash` or `pro` |

## Error Handling

**API key not set**:
```
Error: GEMINI_API_KEY environment variable is not set
→ Set it: export GEMINI_API_KEY='your-api-key'
```

このエラーが出た場合、`~/.zshenv.local` に以下を追記してシェルを再起動してください:
```bash
export GEMINI_API_KEY='your-api-key'
```
※ `~/.zshenv.local` はdotfiles管理外のファイルです。APIキーを平文でgitに入れないための運用です。

**Rate limit exceeded**:
```
Error: Rate limit exceeded
→ Wait a few seconds and retry
```

**Content blocked by safety filter**:
```
Error: No image data in response
→ Modify prompt to avoid potentially sensitive content
```

## Examples

### Example 1: Landing Page Hero

```bash
# First try with flash
python ~/.claude/skills/generating-images/scripts/generate_image.py \
  --prompt "A stunning hero image for a modern tech startup..." \
  --output "./public/images/hero.png" \
  --aspect-ratio "16:9"

# If quality insufficient, retry with pro
python ~/.claude/skills/generating-images/scripts/generate_image.py \
  --prompt "A stunning hero image for a modern tech startup..." \
  --output "./public/images/hero.png" \
  --aspect-ratio "16:9" \
  --quality pro
```

### Example 2: Quick Placeholder

```bash
python ~/.claude/skills/generating-images/scripts/generate_image.py \
  --prompt "A simple placeholder image with subtle gray geometric pattern" \
  --output "./assets/placeholder.png"
```

## Integration

After generating, add to your document:

```markdown
![Hero Image](./assets/images/hero.png)
```

## Dependencies

```bash
pip install google-genai Pillow
```

## Resources

- [Gemini API Image Generation Docs](https://ai.google.dev/gemini-api/docs/image-generation)
