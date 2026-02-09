# Asset Management — Organizing Generated Media

## Overview

Remotion projects accumulate many generated assets — audio, video, images, captions. Consistent organization prevents broken references, makes projects maintainable, and ensures `staticFile()` calls work reliably.

## Checking Existing Assets

Use remotion-media's `list_assets` tool to see all generated media:

```
list_assets:
  project_path: "/path/to/remotion/project"
```

This returns a list of all assets in the project's `public/` directory with filenames, types, and sizes.

## File Organization Standard

```
public/
├── audio/
│   ├── voiceover-intro.mp3
│   ├── voiceover-scene1.mp3
│   ├── music-background-upbeat.mp3
│   ├── sfx-whoosh-transition.mp3
│   └── sfx-pop-text-appear.mp3
├── footage/
│   ├── stock-city-aerial-drone.mp4
│   ├── stock-coffee-pouring.mp4
│   ├── ai-hero-scene-zoom.mp4
│   └── ai-product-showcase.mp4
├── images/
│   ├── background-gradient-blue.png
│   ├── hero-office-golden-hour.png
│   ├── thumbnail-final.png
│   └── logo-white.png
└── captions/
    ├── voiceover-intro.srt
    └── voiceover-scene1.json
```

### Directory Purpose

| Directory | Contents | Source |
|---|---|---|
| `public/audio/` | Voiceovers, music, SFX | remotion-media, ElevenLabs |
| `public/footage/` | Video clips (stock + AI) | Pexels, Replicate, remotion-media |
| `public/images/` | Generated/stock images | Replicate, remotion-media, Pexels |
| `public/captions/` | Subtitle files (SRT, JSON) | remotion-media (Whisper) |

## Naming Conventions

### Pattern: `[type]-[description]-[detail].ext`

**Audio files:**
- `voiceover-intro.mp3` — narration for intro scene
- `voiceover-scene2-features.mp3` — narration about features
- `music-background-jazz.mp3` — jazz background track
- `sfx-whoosh-transition.mp3` — transition sound effect
- `sfx-pop-text.mp3` — text appearance pop

**Video files:**
- `stock-city-aerial-sunset.mp4` — stock footage from Pexels
- `ai-product-rotate-360.mp4` — AI-generated product video
- `ai-abstract-fluid-gold.mp4` — AI-generated abstract clip

**Image files:**
- `background-gradient-dark.png` — dark gradient background
- `hero-office-interior.png` — AI hero image
- `stock-team-meeting.jpg` — stock photo from Pexels
- `logo-brand-white.png` — brand logo

**Caption files:**
- `voiceover-intro.srt` — SRT subtitles for intro voiceover
- `voiceover-intro.json` — JSON word-level timestamps for captions

### What to Avoid

- `output.mp3`, `image1.png`, `video.mp4` — meaningless names
- `final_v2_FINAL_revised.mp3` — version chaos
- Spaces in filenames — use hyphens instead
- Special characters — stick to alphanumeric, hyphens, dots

## Using staticFile()

Remotion accesses all public assets through `staticFile()`:

```tsx
import { Audio, Img, OffthreadVideo, staticFile } from "remotion";

// Audio
<Audio src={staticFile("audio/voiceover-intro.mp3")} volume={1.0} />

// Images
<Img src={staticFile("images/hero-office-interior.png")} />

// Video
<OffthreadVideo src={staticFile("footage/stock-city-aerial.mp4")} />
```

### Common Mistakes

| Mistake | Problem | Fix |
|---|---|---|
| `staticFile("/public/audio/file.mp3")` | Leading slash and `public/` prefix | `staticFile("audio/file.mp3")` |
| `staticFile("./audio/file.mp3")` | Relative path prefix | `staticFile("audio/file.mp3")` |
| `src="/audio/file.mp3"` | Not using staticFile | `src={staticFile("audio/file.mp3")}` |
| `staticFile("audio/My File.mp3")` | Spaces in filename | Rename to `my-file.mp3` |

The path inside `staticFile()` is relative to the `public/` directory. No leading slash, no `public/` prefix, no `./`.

## Asset Audit Workflow

Before rendering, verify all assets are accounted for:

1. **List all assets**: Use `list_assets` to see what's in `public/`
2. **Check references**: Search your Remotion source for `staticFile(` calls
3. **Find orphans**: Assets in `public/` not referenced in code (safe to remove)
4. **Find missing**: `staticFile()` calls pointing to files that don't exist (will break render)

```bash
# Quick check for staticFile references in your Remotion code
grep -r "staticFile(" src/ --include="*.tsx" --include="*.ts"
```

## Best Practices

1. **Organize from the start** — create `audio/`, `footage/`, `images/`, `captions/` subdirectories immediately
2. **Use descriptive names** — your future self (and Claude) will thank you
3. **Never put assets in `src/`** — only `public/` works with `staticFile()`
4. **Run `list_assets` before rendering** — catch missing files early
5. **Delete unused assets** — keeps project size manageable for rendering
6. **Keep original and processed separate** — if you edit an audio file, save as a new name
7. **Match naming to code** — if your component is `IntroScene`, name assets `intro-*`
