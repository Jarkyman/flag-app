# Store listing templates

These are Photoshop-friendly RGB PNG templates for the six version 2.0 store-listing images. Every device screen uses the exact chroma-green color `#00FF00` with no texture or glare over the green area.

All four device sets use the approved premium 3D campaign style as seamless six-panel panoramas. Their ribbon geometry and background shapes continue across all six cuts, while the palette changes at each cut with a hard vertical edge instead of a fade. Devices are almost front-facing with a very small symmetric turn toward the center, and there are no miniature flags, dotted maps or other geographic silhouettes. The frames have no Dynamic Island, notch, camera, speaker or sensor inside the screen.

## Export sizes

| Folder | Canvas size | Ratio / store target |
|---|---:|---|
| `iphone/` | 7704 × 2778 px master | Six App Store slices of 1284 × 2778 px |
| `ipad/` | 12384 × 2752 px master | Six App Store slices of 2064 × 2752 px |
| `android/` | 8640 × 2560 px master | Six Google Play phone slices of 1440 × 2560 px |
| `tablet/` | 10800 × 3200 px master | Six Google Play tablet slices of 1800 × 3200 px |

Each device folder contains one panorama master. Add vertical Photoshop guides at these exact X positions:

### iPhone — `iphone-panorama-master.png`

- 1284 px
- 2568 px
- 3852 px
- 5136 px
- 6420 px

Export the six resulting slices from left to right as 1284 × 2778 px files.

### iPad — `ipad-panorama-master.png`

- 2064 px
- 4128 px
- 6192 px
- 8256 px
- 10320 px

Export as six 2064 × 2752 px files.

### Android phone — `android-panorama-master.png`

- 1440 px
- 2880 px
- 4320 px
- 5760 px
- 7200 px

Export as six 1440 × 2560 px files.

### Android tablet — `tablet-panorama-master.png`

- 1800 px
- 3600 px
- 5400 px
- 7200 px
- 9000 px

Export as six 1800 × 3200 px files.

## Photoshop workflow

1. Open a template and select the solid `#00FF00` screen with Color Range or the Magic Wand.
2. Remove or mask only the green area.
3. Place the matching app screenshot on a layer below the template.
4. Scale the screenshot proportionally, then use **Free Transform > Distort** to align its four corners with the slightly angled green display opening. Keep the screenshot layer below the template so the 3D bezel and bottom ribbons remain in front.
5. Export as a flattened RGB PNG or high-quality JPEG. Google Play files must remain below 8 MB.

The panorama masters are the approved templates. `tool/generate_store_templates.py` is retained only as a legacy source reference and must not be used to overwrite or replace these panoramas.
