#!/usr/bin/env python3
"""
Gemini API Image Generator

Generate images using Google's Gemini API and save them as PNG files.

Usage:
    python generate_image.py --prompt "prompt" --output "output.png"
    python generate_image.py --prompt "prompt" --output "output.png" --quality pro

Models:
    flash: gemini-2.5-flash-image (fast, lightweight - default)
    pro:   gemini-3-pro-image-preview (high quality, slower)

Requirements:
    pip install google-genai Pillow
"""

import argparse
import base64
import os
import sys
from pathlib import Path

try:
    from google import genai
    from google.genai import types
except ImportError:
    print("Error: google-genai package not installed")
    print("Install with: pip install google-genai")
    sys.exit(1)

MODELS = {
    "flash": "gemini-2.5-flash-image",
    "pro": "gemini-3-pro-image-preview",
}


def generate_image(
    prompt: str,
    output_path: str,
    input_path: str | None = None,
    aspect_ratio: str = "1:1",
    quality: str = "flash",
) -> bool:
    """Generate image using Gemini API and save to file.

    Returns:
        True if successful, False otherwise.
    """
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY environment variable is not set")
        print("Set it with: export GEMINI_API_KEY='your-api-key'")
        return False

    client = genai.Client(api_key=api_key)
    model = MODELS.get(quality, MODELS["flash"])

    contents = []

    if input_path:
        try:
            from PIL import Image

            input_image = Image.open(input_path)
            contents.append(input_image)
            print(f"Reference image loaded: {input_path}")
        except ImportError:
            print("Error: Pillow package required for reference images")
            print("Install with: pip install Pillow")
            return False
        except FileNotFoundError:
            print(f"Error: Reference image not found: {input_path}")
            return False

    contents.append(prompt)

    config = types.GenerateContentConfig(
        response_modalities=["TEXT", "IMAGE"],
    )

    print(f"Generating image...")
    print(f"  Model: {model} ({quality})")
    print(f"  Prompt: {prompt[:80]}{'...' if len(prompt) > 80 else ''}")
    print(f"  Aspect ratio: {aspect_ratio}")

    try:
        response = client.models.generate_content(
            model=model,
            contents=contents,
            config=config,
        )
    except Exception as e:
        print(f"Error generating image: {e}")
        return False

    output_dir = Path(output_path).parent
    if output_dir:
        output_dir.mkdir(parents=True, exist_ok=True)

    for part in response.candidates[0].content.parts:
        if hasattr(part, "text") and part.text:
            print(f"Response text: {part.text}")
        elif hasattr(part, "inline_data") and part.inline_data:
            image_data = base64.b64decode(part.inline_data.data)
            with open(output_path, "wb") as f:
                f.write(image_data)
            print(f"Image saved to: {output_path}")
            return True

    print("Error: No image data in response")
    print("The model may have declined to generate this image.")
    return False


def main():
    parser = argparse.ArgumentParser(
        description="Generate images using Gemini API",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Models:
  flash  gemini-2.5-flash-image (fast, lightweight - default)
  pro    gemini-3-pro-image-preview (high quality, slower)

Examples:
  %(prog)s --prompt "A minimalist hero image" --output hero.png
  %(prog)s --prompt "A detailed product photo" --output product.png --quality pro
  %(prog)s --prompt "Add text overlay" --input base.png --output final.png
        """,
    )
    parser.add_argument(
        "--prompt", required=True, help="Image generation prompt (be descriptive)"
    )
    parser.add_argument(
        "--output", required=True, help="Output file path (.png recommended)"
    )
    parser.add_argument("--input", help="Reference image path for editing (optional)")
    parser.add_argument(
        "--aspect-ratio",
        default="1:1",
        choices=["1:1", "16:9", "9:16", "4:3", "3:4", "3:2", "2:3"],
        help="Aspect ratio (default: 1:1)",
    )
    parser.add_argument(
        "--quality",
        default="flash",
        choices=["flash", "pro"],
        help="Model quality: flash (fast) or pro (high quality). Default: flash",
    )

    args = parser.parse_args()

    success = generate_image(
        prompt=args.prompt,
        output_path=args.output,
        input_path=args.input,
        aspect_ratio=args.aspect_ratio,
        quality=args.quality,
    )

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
