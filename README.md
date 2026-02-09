# 🎬 Remotion Superpowers

A Claude Code plugin that turns Remotion from a motion graphics tool into a **full video production studio**. 

Gives Claude the power to **see** (video analysis), **hear** (music generation), **speak** (voiceovers), and **source** (stock footage) — all wired into Remotion's React-based video pipeline.

## What This Plugin Does

| Capability | Tool | What It Enables |
|---|---|---|
| 🎵 Music Generation | Suno (via KIE) | Generate background music from text descriptions |
| 🗣️ Voiceovers | ElevenLabs TTS (via KIE) | Generate natural narration from scripts |
| 🔊 Sound Effects | ElevenLabs SFX (via KIE) | Generate sound effects from descriptions |
| 👁️ Video Analysis | TwelveLabs | "See" existing footage — find scenes, detect objects, pick timestamps |
| 📸 Stock Footage | Pexels | Search and download free HD/4K stock video and photos |
| 🖼️ Image Generation | Nano Banana Pro (via KIE) | Generate images from text prompts |
| 🎬 Video Generation | Veo 3.1 (via KIE) | Generate video clips from text/images |
| 📝 Subtitles | Whisper (via KIE) | Transcribe audio/video to SRT subtitle files |
| 🎯 Remotion Knowledge | Remotion Skills | Best practices for animations, audio, compositions, and more |

## Installation

```bash
# In Claude Code:
/plugin marketplace add DojoCodingLabs/remotion-superpowers
/plugin install remotion-superpowers@remotion-superpowers
```

That's it. Run `/setup` to configure your API keys.

**Requires:** Claude Code with plugin support. MCP servers use `npx` and `uvx` — install [Node.js](https://nodejs.org) and [uv](https://astral.sh/uv) if needed.

### Updating

```bash
# Update the marketplace catalog first:
claude plugin marketplace update DojoCodingLabs/remotion-superpowers

# Then update the plugin:
claude plugin update remotion-superpowers@remotion-superpowers
```

Restart your Claude Code session after updating.

### Local Development

```bash
git clone https://github.com/DojoCodingLabs/remotion-superpowers.git
cd remotion-superpowers

# In Claude Code:
/plugin marketplace add .
/plugin install remotion-superpowers
```

## Quick Start

### 1. Run setup

```
/setup
```

This walks you through:
- Checking dependencies (Node.js, npm, Python, uv)
- Creating or detecting a Remotion project
- Installing Remotion skills
- Configuring API keys for all services
- Verifying MCP server connections

### 2. Create a video

```
/create-video
```

Or just describe what you want:

> "Create a 30-second promo video for a coffee shop. Include drone footage of a city, 
> a warm voiceover, background jazz music, and animated text overlays with the shop's 
> name and address."

## Commands

| Command | Description |
|---|---|
| `/setup` | First-run wizard — installs everything you need |
| `/create-video` | Full video production pipeline from concept to render |
| `/find-footage` | Search & download stock footage from Pexels |
| `/analyze-footage` | Use AI to understand existing video files |
| `/add-voiceover` | Generate and add narration to your video |
| `/add-music` | Generate and add background music |

## API Keys Required

| Service | Variable | Required? | Cost | What It Provides |
|---|---|---|---|---|
| KIE | `KIE_API_KEY` | ✅ Yes | Paid | Music, SFX, TTS, images, video, subtitles |
| TwelveLabs | `TWELVELABS_API_KEY` | ✅ Yes | Free tier | Video understanding & analysis |
| Pexels | `PEXELS_API_KEY` | Recommended | Free | Stock photos & videos |
| ElevenLabs | `ELEVENLABS_API_KEY` | Optional | Free tier | Advanced voice cloning & custom voices |

## MCP Servers

This plugin auto-configures 4 MCP servers:

- **remotion-media** — Primary media generation (Suno + ElevenLabs + Whisper + more via KIE)
- **TwelveLabs** — Video understanding and scene analysis
- **Pexels** — Free stock footage and photos
- **ElevenLabs** — Advanced voice features (optional)

## How It Works

```
Your Prompt → /create-video
    │
    ├── 1. Concept → Break into scenes, script, audio needs
    ├── 2. Script → Generate narration text + timing
    ├── 3. Voiceover → Generate TTS audio (remotion-media / ElevenLabs)
    ├── 4. Music → Generate background music (Suno via remotion-media)
    ├── 5. Footage → Search Pexels / analyze local files with TwelveLabs
    ├── 6. Visuals → Write Remotion React components
    ├── 7. Compose → Wire all assets into composition
    ├── 8. Preview → npm run dev (live preview)
    └── 9. Render → npx remotion render (final MP4)
```

## Project Structure

```
remotion-superpowers/
├── .claude-plugin/plugin.json    # Plugin metadata
├── .mcp.json                     # MCP server configurations
├── commands/                     # Slash commands
│   ├── setup.md                  # /setup
│   ├── create-video.md           # /create-video
│   ├── find-footage.md           # /find-footage
│   ├── analyze-footage.md        # /analyze-footage
│   ├── add-voiceover.md          # /add-voiceover
│   └── add-music.md              # /add-music
├── agents/                       # Specialized agents
│   ├── video-director.md         # Orchestrates full pipeline
│   └── media-scout.md            # Finds & evaluates media
├── skills/                       # Domain knowledge
│   ├── remotion-production/      # Full production workflow skill
│   └── setup-guide/              # Setup & onboarding knowledge
├── hooks/hooks.json              # Pre-tool MCP health checks
├── scripts/setup-check.sh        # Dependency validation script
└── README.md
```

## Built by Dojo Coding Labs

[Dojo Coding](https://dojocoding.io) is a LATAM-first tech education ecosystem. We build tools for developers and teach people to code.

**remotion-superpowers** is free forever. Open source. MIT licensed.

### More from Dojo Coding

- [CodeSensei](https://github.com/DojoCodingLabs/code-sensei) — Learn to code while you vibecode
- [juan-workflow](https://github.com/DojoCodingLabs/juan-workflow) — Dev lifecycle guardrails
- [VibeCoding Bootcamp](https://dojocoding.io) — Structured curriculum with live mentors

## License

MIT License — free to use, modify, and distribute.

---

🎬 From prompt to production — one `/create-video` at a time.

Free. Open source. By [Dojo Coding Labs](https://dojocoding.io).
