# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Static personal website and photography portfolio for rickslot.nl, hosted via GitHub Pages.

## Architecture

- **`index.html`** — Landing page with profile info and social links. Age is calculated dynamically from birthdate.
- **`portfolio.html`** — Photo gallery that fetches `photos.json`, renders a CSS grid with orientation-aware layout (portrait/landscape sizing), and includes a lightbox with EXIF data overlay and keyboard navigation.
- **`photos.json`** — Generated file (do not edit manually). Contains photo metadata (EXIF data, dimensions) for each `.jpg` in `photos/`.
- **`build_portfolio.sh`** — Build script that generates thumbnails and `photos.json`. Requires macOS tools: `sips`, `exiftool`, `jq`.

## Build

To regenerate thumbnails and `photos.json` after adding/removing photos:

```
./build_portfolio.sh
```

This creates thumbnails in `photos/thumbnails/` (600px max dimension via `sips`), extracts EXIF data via `exiftool`, and stages the generated files in git.

## Development

No build system or package manager. Open HTML files directly in a browser or use any local HTTP server (e.g., `python3 -m http.server`). The portfolio page requires a server due to `fetch('photos.json')`.

## Key Details

- Custom domain: `rickslot.nl` (configured in `CNAME`)
- All styling is inline within each HTML file (no external CSS files)
- All JS is inline within each HTML file (no external JS files)
- Photos are `.jpg` files in `photos/`; thumbnails are auto-generated and should not be manually edited
