#!/usr/bin/env python3
"""Generate Photoshop-friendly store-listing templates with chroma-green screens."""

from __future__ import annotations

import math
import random
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_ROOT = ROOT / "docs" / "templates"
WORLD_MAP = ROOT / "assets" / "image" / "dotted_world_map.svg"
GREENSCREEN = (0, 255, 0)
TEXT_COLOR = (29, 27, 31)

FONT_CANDIDATES = (
    Path("/Library/Fonts/SF-Pro-Rounded-Black.otf"),
    Path("/System/Library/Fonts/Supplemental/Arial Black.ttf"),
)


@dataclass(frozen=True)
class Format:
    folder: str
    width: int
    height: int
    device: str


@dataclass(frozen=True)
class CampaignCard:
    slug: str
    headline: str
    top: tuple[int, int, int]
    bottom: tuple[int, int, int]
    accent: tuple[int, int, int]
    accent_dark: tuple[int, int, int]


FORMATS = (
    Format("ipad", 2064, 2752, "ipad"),
    Format("android", 1440, 2560, "android"),
    Format("tablet", 1800, 3200, "tablet"),
)


CARDS = (
    CampaignCard(
        "know-the-world",
        "KNOW THE\nWORLD?",
        (238, 252, 251),
        (205, 244, 239),
        (31, 186, 176),
        (12, 132, 126),
    ),
    CampaignCard(
        "guess-197-countries",
        "GUESS 197\nCOUNTRIES",
        (255, 248, 244),
        (255, 225, 214),
        (255, 111, 97),
        (221, 71, 60),
    ),
    CampaignCard(
        "learn-as-you-play",
        "LEARN AS\nYOU PLAY",
        (255, 252, 235),
        (255, 241, 194),
        (255, 190, 24),
        (224, 145, 0),
    ),
    CampaignCard(
        "find-the-right-flag",
        "FIND THE\nRIGHT FLAG",
        (255, 247, 243),
        (255, 222, 214),
        (255, 105, 91),
        (222, 71, 59),
    ),
    CampaignCard(
        "match-flags-fast",
        "MATCH FLAGS\nFAST",
        (249, 246, 255),
        (232, 224, 255),
        (128, 102, 214),
        (87, 58, 179),
    ),
    CampaignCard(
        "spot-the-country",
        "SPOT THE\nCOUNTRY",
        (243, 249, 255),
        (218, 236, 255),
        (55, 153, 235),
        (15, 103, 194),
    ),
)


def _font_path() -> Path:
    for path in FONT_CANDIDATES:
        if path.exists():
            return path
    raise FileNotFoundError("No supported headline font was found")


def _interpolate(a: int, b: int, amount: float) -> int:
    return round(a + (b - a) * amount)


def _vertical_gradient(width: int, height: int, top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    image = Image.new("RGB", (width, height))
    draw = ImageDraw.Draw(image)
    for y in range(height):
        amount = y / max(1, height - 1)
        color = tuple(_interpolate(top[channel], bottom[channel], amount) for channel in range(3))
        draw.line((0, y, width, y), fill=color)
    return image.convert("RGBA")


def _svg_circles() -> tuple[list[tuple[float, float, float]], tuple[float, float]]:
    root = ET.parse(WORLD_MAP).getroot()
    view_box = [float(value) for value in root.attrib["viewBox"].split()]
    circles: list[tuple[float, float, float]] = []
    for element in root.iter():
        if element.tag.endswith("circle"):
            circles.append(
                (
                    float(element.attrib["cx"]),
                    float(element.attrib["cy"]),
                    float(element.attrib["r"]),
                )
            )
    return circles, (view_box[2], view_box[3])


MAP_CIRCLES, MAP_SIZE = _svg_circles()


def _add_world_map(base: Image.Image, card: CampaignCard, fmt: Format) -> None:
    width, height = base.size
    map_width = int(width * (1.22 if fmt.device in {"iphone", "android"} else 1.08))
    map_height = int(map_width * MAP_SIZE[1] / MAP_SIZE[0])
    map_layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(map_layer)
    left = (width - map_width) // 2
    top = -int(map_height * 0.08)
    scale = map_width / MAP_SIZE[0]
    dot_color = (*card.accent, 46)
    for cx, cy, radius in MAP_CIRCLES:
        x = left + cx * scale
        y = top + cy * scale
        r = max(1.0, radius * scale)
        draw.ellipse((x - r, y - r, x + r, y + r), fill=dot_color)
    base.alpha_composite(map_layer)


def _add_background_shapes(base: Image.Image, card: CampaignCard, variant: int) -> None:
    width, height = base.size
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    side = -1 if variant % 2 == 0 else 1
    circle_size = int(width * 0.56)
    circle_x = int(width * (0.80 if side > 0 else -0.08))
    circle_y = int(height * 0.21)
    draw.ellipse(
        (circle_x, circle_y, circle_x + circle_size, circle_y + circle_size),
        fill=(*card.accent, 56),
    )

    second_size = int(width * 0.42)
    second_x = int(width * (-0.13 if side > 0 else 0.72))
    second_y = int(height * 0.50)
    draw.ellipse(
        (second_x, second_y, second_x + second_size, second_y + second_size),
        fill=(*card.accent_dark, 35),
    )
    base.alpha_composite(layer)


def _add_confetti(base: Image.Image, card: CampaignCard, variant: int) -> None:
    width, height = base.size
    randomizer = random.Random(7102026 + variant * 101 + width + height)
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    colors = (
        card.accent,
        card.accent_dark,
        (255, 196, 32),
        (44, 143, 224),
        (239, 80, 91),
    )

    count = 12 if width < 1700 else 18
    for index in range(count):
        on_left = index % 2 == 0
        x = randomizer.uniform(0.025, 0.15) * width if on_left else randomizer.uniform(0.85, 0.975) * width
        y = randomizer.uniform(0.10, 0.72) * height
        size = randomizer.uniform(0.018, 0.038) * width
        color = colors[index % len(colors)]
        if index % 3 == 0:
            draw.regular_polygon(
                (x, y, size * 0.64),
                n_sides=4,
                rotation=randomizer.uniform(10, 45),
                fill=(*color, 225),
            )
        else:
            draw.rounded_rectangle(
                (x - size / 2, y - size / 3, x + size / 2, y + size / 3),
                radius=max(2, int(size * 0.10)),
                fill=(*color, 220),
            )
    base.alpha_composite(layer)


def _fit_headline_font(text: str, max_width: int, max_height: int, initial_size: int) -> ImageFont.FreeTypeFont:
    font_path = _font_path()
    size = initial_size
    while size > 48:
        font = ImageFont.truetype(str(font_path), size=size)
        box = ImageDraw.Draw(Image.new("L", (1, 1))).multiline_textbbox(
            (0, 0),
            text,
            font=font,
            spacing=int(size * 0.02),
            align="center",
            stroke_width=0,
        )
        if box[2] - box[0] <= max_width and box[3] - box[1] <= max_height:
            return font
        size -= 2
    return ImageFont.truetype(str(font_path), size=48)


def _add_headline(base: Image.Image, card: CampaignCard, fmt: Format) -> None:
    width, height = base.size
    if fmt.device in {"iphone", "android"}:
        top = int(height * 0.032)
        max_height = int(height * 0.165)
        initial_size = int(height * 0.069)
        max_width = int(width * 0.88)
    else:
        top = int(height * 0.034)
        max_height = int(height * 0.18)
        initial_size = int(height * 0.074)
        max_width = int(width * 0.86)

    font = _fit_headline_font(card.headline, max_width, max_height, initial_size)
    draw = ImageDraw.Draw(base)
    box = draw.multiline_textbbox(
        (0, 0), card.headline, font=font, spacing=int(font.size * 0.02), align="center"
    )
    text_width = box[2] - box[0]
    draw.multiline_text(
        ((width - text_width) / 2, top),
        card.headline,
        fill=TEXT_COLOR,
        font=font,
        spacing=int(font.size * 0.02),
        align="center",
    )


def _device_geometry(fmt: Format, variant: int) -> tuple[int, int, int, int, float]:
    width, height = fmt.width, fmt.height
    horizontal_shift = (-0.035, 0.028, -0.018, 0.034, -0.025, 0.020)[variant]

    if fmt.device == "iphone":
        body_width = int(width * 0.79)
        body_height = int(body_width / 0.462)
        top = int(height * 0.205)
        radius_ratio = 0.085
    elif fmt.device == "android":
        body_width = int(width * 0.80)
        body_height = int(body_width / 0.455)
        top = int(height * 0.205)
        radius_ratio = 0.065
    elif fmt.device == "ipad":
        body_width = int(width * 0.84)
        body_height = int(body_width / 0.748)
        top = int(height * 0.205)
        radius_ratio = 0.050
    else:
        body_width = int(width * 0.86)
        body_height = int(body_width / 0.605)
        top = int(height * 0.205)
        radius_ratio = 0.048

    left = int((width - body_width) / 2 + width * horizontal_shift)
    return left, top, body_width, body_height, radius_ratio


def _add_device(base: Image.Image, fmt: Format, variant: int) -> None:
    left, top, body_width, body_height, radius_ratio = _device_geometry(fmt, variant)
    right, bottom = left + body_width, top + body_height
    radius = int(body_width * radius_ratio)

    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_offset = int(body_width * 0.026)
    shadow_draw.rounded_rectangle(
        (left + shadow_offset, top + shadow_offset, right + shadow_offset, bottom + shadow_offset),
        radius=radius,
        fill=(25, 27, 32, 118),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(max(10, int(body_width * 0.030))))
    base.alpha_composite(shadow)

    draw = ImageDraw.Draw(base)
    draw.rounded_rectangle((left, top, right, bottom), radius=radius, fill=(31, 33, 37))

    metal = max(7, int(body_width * 0.014))
    draw.rounded_rectangle(
        (left + metal, top + metal, right - metal, bottom - metal),
        radius=max(1, radius - metal),
        fill=(181, 187, 191),
    )

    bezel = max(10, int(body_width * (0.030 if fmt.device in {"iphone", "android"} else 0.024)))
    draw.rounded_rectangle(
        (left + metal * 2, top + metal * 2, right - metal * 2, bottom - metal * 2),
        radius=max(1, radius - metal * 2),
        fill=(16, 17, 19),
    )

    screen_left = left + metal * 2 + bezel
    screen_top = top + metal * 2 + bezel
    screen_right = right - metal * 2 - bezel
    screen_bottom = bottom - metal * 2 - bezel
    screen_radius = max(16, radius - metal * 2 - int(bezel * 0.45))
    draw.rounded_rectangle(
        (screen_left, screen_top, screen_right, screen_bottom),
        radius=screen_radius,
        fill=GREENSCREEN,
    )

    edge_width = max(3, int(body_width * 0.004))
    draw.rounded_rectangle(
        (left, top, right, bottom),
        radius=radius,
        outline=(244, 247, 248, 190),
        width=edge_width,
    )

    if fmt.device == "iphone":
        pill_width = int(body_width * 0.22)
        pill_height = int(body_height * 0.026)
        pill_left = left + (body_width - pill_width) // 2
        pill_top = top + metal * 2 + int(bezel * 0.55)
        draw.rounded_rectangle(
            (pill_left, pill_top, pill_left + pill_width, pill_top + pill_height),
            radius=pill_height // 2,
            fill=(10, 11, 12),
        )
    else:
        camera_radius = max(5, int(body_width * 0.008))
        camera_y = top + metal * 2 + int(bezel * 0.62)
        draw.ellipse(
            (
                left + body_width / 2 - camera_radius,
                camera_y - camera_radius,
                left + body_width / 2 + camera_radius,
                camera_y + camera_radius,
            ),
            fill=(7, 8, 10),
        )

    button_width = max(4, int(body_width * 0.008))
    button_height = int(body_height * 0.090)
    button_top = top + int(body_height * 0.22)
    draw.rounded_rectangle(
        (right - button_width // 2, button_top, right + button_width // 2, button_top + button_height),
        radius=max(2, button_width // 2),
        fill=(75, 78, 82),
    )


def _wave_points(width: int, height: int, baseline: float, amplitude: float, phase: float) -> list[tuple[float, float]]:
    points: list[tuple[float, float]] = [(0, height)]
    steps = 72
    for index in range(steps + 1):
        x = width * index / steps
        y = baseline + math.sin(index / steps * math.pi * 2 + phase) * amplitude
        points.append((x, y))
    points.append((width, height))
    return points


def _add_bottom_waves(base: Image.Image, card: CampaignCard, variant: int) -> None:
    width, height = base.size
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    draw.polygon(
        _wave_points(width, height, height * 0.905, height * 0.020, variant * 0.7),
        fill=(*card.accent, 225),
    )
    draw.polygon(
        _wave_points(width, height, height * 0.942, height * 0.016, variant * 0.7 + 1.5),
        fill=(*card.accent_dark, 245),
    )
    base.alpha_composite(layer)


def _render(fmt: Format, card: CampaignCard, variant: int) -> Image.Image:
    image = _vertical_gradient(fmt.width, fmt.height, card.top, card.bottom)
    _add_world_map(image, card, fmt)
    _add_background_shapes(image, card, variant)
    _add_confetti(image, card, variant)
    _add_headline(image, card, fmt)
    _add_device(image, fmt, variant)
    _add_bottom_waves(image, card, variant)
    return image.convert("RGB")


def main() -> None:
    for fmt in FORMATS:
        output_dir = OUTPUT_ROOT / fmt.folder
        output_dir.mkdir(parents=True, exist_ok=True)
        for index, card in enumerate(CARDS, start=1):
            image = _render(fmt, card, index - 1)
            output = output_dir / f"{index:02d}-{card.slug}.png"
            image.save(output, format="PNG", optimize=True)
            print(f"{output.relative_to(ROOT)}: {image.width}x{image.height}")


if __name__ == "__main__":
    main()
