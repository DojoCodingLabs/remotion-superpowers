# Asset Management — Organizing Generated Media

## Overview

Remotion projects accumulate many generated assets — audio, video, images, captions. Consistent organization prevents broken references, makes projects maintainable, and ensures `staticFile()` calls work reliably.

## Where Files Land

There is one convention, and it follows from how the tools write files:

| Source | Lands in | How the type is encoded |
|---|---|---|
| Audio script (`scripts/generate-audio.ts`, official ElevenLabs skills) | `public/<name>.mp3`, the `public/` **root** | The `name` in the script: `vo-`, `music-`, `sfx-` |
| remotion-media tools (`generate_image`, `generate_video_from_*`; `generate_speech`, `generate_music`, `generate_sound_effect` for drafts) | `public/<output_name>.<ext>`, the `public/` **root** | Prefix in `output_name`: `img-`, `clip-`, `vo-`, `music-`, `sfx-` |
| ElevenLabs MCP, deprecated (`text_to_speech`, `text_to_sound_effects`, `compose_music`, `isolate_audio`, …) | `public/`, because its base path is `./public`. It also only reads input files from inside `public/`. | Leave `output_directory` out or pass the absolute `public/` path, then rename to the convention (it picks its own filenames) |
| Captions you transcribe (`captions-workflow.md`) | `public/<source>.captions.json`, and `public/<source>.srt` if exported | Named after the source file |
| Files you download yourself (Pexels, Replicate) | `public/footage/` and `public/images/` | Folder, after `mkdir -p public/footage public/images` |
| Hosted SFX (`https://remotion.media/*.wav`) | Nowhere; use the URL as `src` | — |

The remotion-media tools can't write into subfolders, so keep generated media at the root with a type prefix, and don't create `public/audio/`. Everything generated lands at the root the same way, whichever route made it. remotion-media and the ElevenLabs MCP both resolve `public/` against the directory the agent was launched from, so start the agent from the Remotion project root.

This replaces the `public/voiceover/<compositionId>/` layout in the official voiceover guide: one flat, prefixed root works the same for every tool.

```
public/
├── vo-scene1.mp3                  # scripts/generate-audio.ts
├── vo-scene2.mp3
├── music-bg.mp3                   # scripts/generate-audio.ts
├── sfx-whoosh-transition.mp3      # scripts/generate-audio.ts
├── img-hero-office.png            # generate_image
├── clip-city-aerial.mp4           # generate_video_from_text / _from_image
├── vo-scene1.captions.json        # word-level captions (Caption[])
├── vo-scene1.srt                  # optional SRT export
├── footage/                       # downloaded by you
│   ├── stock-city-aerial-sunset.mp4
│   └── replicate-product-rotate.mp4
└── images/
    ├── stock-team-meeting.jpg
    ├── replicate-hero-flux.png
    └── logo-white.png
```

## Naming Conventions

### Pattern: `[type]-[description]-[detail]`

This is the `name` in the audio script and the `output_name` for remotion-media tools (no extension; the script and the tools add it).

| Type | Prefix | Examples |
|---|---|---|
| Voiceover | `vo-` | `vo-scene1`, `vo-scene2-features`, `vo-line03-guest` |
| Music | `music-` | `music-bg`, `music-intro`, `music-bg-jazz` |
| Sound effect | `sfx-` | `sfx-whoosh-transition`, `sfx-pop-text` |
| AI image | `img-` | `img-hero-office`, `img-bg-gradient-dark` |
| AI clip | `clip-` | `clip-city-aerial`, `clip-product-rotate` |
| Stock footage (downloaded) | `footage/stock-` | `footage/stock-coffee-pouring.mp4` |
| Stock photo (downloaded) | `images/stock-` | `images/stock-team-meeting.jpg` |
| Replicate output (downloaded) | `footage/` or `images/` + `replicate-` | `images/replicate-hero-flux.png` |

Captions take the source file's name: `vo-scene1.mp3` gives `vo-scene1.captions.json` (word-level `Caption[]`) and, if exported, `vo-scene1.srt`. User-supplied SRT files keep their name in `public/` and are read with `parseSrt()`.

### What to Avoid

- `output.mp3`, `image1.png`, `video.mp4` — meaningless names
- `final_v2_FINAL_revised.mp3` — version chaos
- Spaces in filenames — use hyphens instead
- Special characters — stick to alphanumeric, hyphens, dots

## Using staticFile()

Remotion accesses public assets through `staticFile()` with the exact path relative to `public/`. Place them with `<Audio>`/`<Video>` from `@remotion/media` and `<Img>` from `remotion`, following the official `remotion-markup` skill:

```tsx
import { Audio, Video } from "@remotion/media";
import { Img, staticFile } from "remotion";

<Audio src={staticFile("vo-scene1.mp3")} />            // generated: root
<Img src={staticFile("img-hero-office.png")} />         // generated: root
<Video src={staticFile("footage/stock-city-aerial-sunset.mp4")} />  // downloaded: subfolder
```

### Common Mistakes

| Mistake | Problem | Fix |
|---|---|---|
| `staticFile("/public/vo-scene1.mp3")` | Leading slash and `public/` prefix | `staticFile("vo-scene1.mp3")` |
| `staticFile("./vo-scene1.mp3")` | Relative path prefix | `staticFile("vo-scene1.mp3")` |
| `staticFile("audio/vo-scene1.mp3")` | Generated audio is at the root, not in `audio/` | `staticFile("vo-scene1.mp3")` |
| `staticFile("stock-city.mp4")` | Downloaded footage lives in `footage/` | `staticFile("footage/stock-city.mp4")` |
| `src="/vo-scene1.mp3"` | Not using staticFile | `src={staticFile("vo-scene1.mp3")}` |
| `staticFile("footage/My File.mp4")` | Spaces in filename | Rename to `my-file.mp4` |

The path inside `staticFile()` is relative to the `public/` directory. No leading slash, no `public/` prefix, no `./`.

## The Asset Library (`list_assets`)

`list_assets` is **not** a view of `public/`. It browses the Airtable asset library that remotion-media keeps when `AIRTABLE_API_KEY` is set: files someone backed up with `backup_asset`, each with an AID, filename, description, file type and creation date.

```
list_assets:
  file_type: "audio"   # optional: image, video, audio, subtitle, other
  max_records: 20      # optional, max 100
```

- To reuse a library asset, pull it with `get_asset` (`aid: "A42"`, `target_dir: "public"`). It saves with an AID prefix, so reference that exact filename in `staticFile()`.
- To keep an asset for later projects, `backup_asset` it (`file_path: "public/music-bg.mp3"`, plus a `description`).
- To see what's in the current project, use `ls -R public/`.

## Asset Audit Workflow

Before a render or a `review-video` run, verify all assets are accounted for:

1. **List all assets**: Run `ls -R public/` to see what's in `public/`
2. **Check references**: Search your Remotion source for `staticFile(` calls
3. **Find orphans**: Assets in `public/` not referenced in code (safe to remove)
4. **Find missing**: `staticFile()` calls pointing to files that don't exist (will break render)

```bash
# Quick check for staticFile references in your Remotion code
grep -r "staticFile(" src/ --include="*.tsx" --include="*.ts"
```

## Best Practices

1. **Follow the convention from the start** — type prefixes at the `public/` root for everything generated; `footage/` and `images/` only for files you download
2. **Use descriptive names** — your future self (and Claude) will thank you
3. **Never put assets in `src/`** — only `public/` works with `staticFile()`
4. **Run `ls -R public/` before a render** — catch missing files early
5. **Delete unused assets** — keeps project size manageable for rendering
6. **Keep original and processed separate** — if you edit an audio file, save as a new name
7. **Match naming to code** — if your component is `IntroScene`, name assets `intro-*`
