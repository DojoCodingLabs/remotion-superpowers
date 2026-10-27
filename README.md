<p align="center">
  <a href="https://dojocoding.io">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="docs/assets/banner-dark.svg">
      <source media="(prefers-color-scheme: light)" srcset="docs/assets/banner-light.svg">
      <img alt="Remotion Superpowers by Dojo Coding: Turns Remotion into a full video studio" src="docs/assets/banner-light.svg" width="100%">
    </picture>
  </a>
</p>

<p align="center">
  <strong>One prompt in, a finished MP4 out.</strong><br>
  Voiceover, music, sound effects, stock footage, AI images and clips, TikTok captions, transitions, and an AI review loop,<br>
  all wired into <a href="https://www.remotion.dev">Remotion</a> by your coding agent.
</p>

<p align="center">
  <a href="https://github.com/DojoCodingLabs/remotion-superpowers/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/DojoCodingLabs/remotion-superpowers?style=flat&logo=github&color=FF7151&labelColor=201E3D"></a>
  <a href="https://github.com/DojoCodingLabs/remotion-superpowers/network/members"><img alt="GitHub forks" src="https://img.shields.io/github/forks/DojoCodingLabs/remotion-superpowers?style=flat&logo=github&color=FF7151&labelColor=201E3D"></a>
  <a href="https://github.com/DojoCodingLabs/remotion-superpowers/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/DojoCodingLabs/remotion-superpowers?color=FF7151&labelColor=201E3D"></a>
  <a href="https://github.com/DojoCodingLabs/remotion-superpowers/actions/workflows/validate.yml"><img alt="CI" src="https://img.shields.io/github/actions/workflow/status/DojoCodingLabs/remotion-superpowers/validate.yml?branch=main&label=CI&labelColor=201E3D"></a>
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-FF7151?labelColor=201E3D"></a>
</p>

<p align="center">
  <a href="#claude-code"><img alt="Claude Code" src="https://img.shields.io/badge/Claude%20Code-plugin-201E3D?labelColor=201E3D"></a>
  <a href="#codex"><img alt="Codex" src="https://img.shields.io/badge/Codex-plugin-201E3D?labelColor=201E3D"></a>
  <a href="#gemini-cli"><img alt="Gemini CLI" src="https://img.shields.io/badge/Gemini%20CLI-extension-201E3D?labelColor=201E3D"></a>
  <a href="#cursor-github-copilot-and-other-agents"><img alt="Agent Skills" src="https://img.shields.io/badge/Agent%20Skills-15-201E3D?labelColor=201E3D"></a>
  <a href="#mcp-servers"><img alt="MCP servers" src="https://img.shields.io/badge/MCP%20servers-5-201E3D?labelColor=201E3D"></a>
</p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="#quick-start">Quick start</a> ·
  <a href="#commands">Commands</a> ·
  <a href="#api-keys">API keys</a> ·
  <a href="#troubleshooting">Troubleshooting</a> ·
  <a href="CONTRIBUTING.md">Contribute</a>
</p>

---

```text
> /create-video "30-second promo for a coffee shop: drone shot of the city,
                 warm voiceover, background jazz, animated shop name and address"

  ✓ script & scene plan       ✓ voiceover (ElevenLabs)     ✓ jazz track (Suno)
  ✓ city footage (Pexels)     ✓ captions (Whisper)         ✓ transitions
  ✓ live preview in Studio   ✓ render → out/video.mp4     ✓ AI review → fixes
```

Remotion turns React into video, and [Remotion's official Agent Skills](https://www.remotion.dev/docs/ai/skills) teach your agent how to write it. **Remotion Superpowers** layers on top and gives your agent everything else a video needs. It can **see** (video analysis), **speak** (voiceovers), **hear** (music and SFX), **source** (stock footage and AI generation), **caption**, **transition**, and **review** its own render, then fix it.

## Install

| Agent | Start with (full steps below) |
|---|---|
| [Claude Code](#claude-code) | `/plugin marketplace add DojoCodingLabs/remotion-superpowers` |
| [Codex](#codex) | `codex plugin marketplace add DojoCodingLabs/remotion-superpowers` |
| [Gemini CLI](#gemini-cli) | `gemini extensions install https://github.com/DojoCodingLabs/remotion-superpowers` |
| [Cursor, Copilot, others](#cursor-github-copilot-and-other-agents) | `npx skills add DojoCodingLabs/remotion-superpowers` |

**Requires** [Node.js](https://nodejs.org) 18+ and [uv](https://astral.sh/uv) (the MCP servers run through `npx` and `uvx`), plus Remotion's official skills, which `/setup` installs for you (or run `npx skills add remotion-dev/skills`).

### Claude Code

```bash
/plugin marketplace add DojoCodingLabs/remotion-superpowers
/plugin install remotion-superpowers@remotion-superpowers
```

Then run `/setup`.

### Codex

```bash
codex plugin marketplace add DojoCodingLabs/remotion-superpowers
codex plugin add remotion-superpowers@remotion-superpowers
```

Export your [API keys](#api-keys) in the shell you start Codex from; the plugin forwards them to the MCP servers. Then ask Codex to run the `setup` skill.

### Gemini CLI

```bash
gemini extensions install https://github.com/DojoCodingLabs/remotion-superpowers
```

Gemini asks for each API key during install (leave the optional ones blank). Change one later with `gemini extensions config remotion-superpowers "KIE API key"`.

### Cursor, GitHub Copilot, and other agents

```bash
npx skills add DojoCodingLabs/remotion-superpowers
```

This installs the 15 skills into every agent it detects. Then add the servers from [`.mcp.json`](.mcp.json) to your agent's MCP config and set the keys listed under each server's `env_vars`.

> [!NOTE]
> **Built on Remotion's official skills.** They own the Remotion markup, preview and render; this plugin owns the media: generating, sourcing, analyzing and reviewing it. When both are installed, each sticks to its part.
>
> Skills and MCP servers work in every agent above. The 3 subagents in `agents/` and the hooks (API-key guard, captions tip) are Claude Code extras.

<details>
<summary><strong>Updating</strong></summary>

| Agent | Update |
|---|---|
| Claude Code | `claude plugin marketplace update DojoCodingLabs/remotion-superpowers`, then `claude plugin update remotion-superpowers@remotion-superpowers`, and restart the session |
| Codex | `codex plugin marketplace upgrade` |
| Gemini CLI | `gemini extensions update remotion-superpowers` |
| Agent Skills | `npx skills update` |

</details>

<details>
<summary><strong>Local development</strong></summary>

```bash
git clone https://github.com/DojoCodingLabs/remotion-superpowers.git
cd remotion-superpowers

# In Claude Code:
/plugin marketplace add .
/plugin install remotion-superpowers
```

Run `bash scripts/ci/validate.sh` before opening a PR. CI runs the same checks.

</details>

## Quick start

**1. Set up.** Run `/setup` to check dependencies, create or detect a Remotion project, install Remotion's official skills, configure API keys, and verify the MCP servers.

**2. Make a video.** Run `/create-video`, or just describe it. Remotion Studio opens right away, so you can watch the video come together and steer:

> "Create a 30-second promo video for a coffee shop. Include drone footage of a city, a warm voiceover, background jazz music, and animated text overlays with the shop's name and address."

**3. Render and make it better.** Ask for the MP4 when you're happy, or run `/review-video`: the agent renders, watches the result, lists what to fix, fixes it, and re-renders.

> [!TIP]
> Start your agent from the Remotion project root. Generated audio, images and clips land in that directory's `public/`.

## What you get

| | Capability | Powered by |
|---|---|---|
| 🗣️ | Voiceovers from a script | ElevenLabs TTS (via KIE) |
| 🎵 | Background music from a mood | Suno (via KIE) |
| 🔊 | Sound effects from a description | ElevenLabs SFX (via KIE) |
| 📸 | Free HD/4K stock video and photos | Pexels |
| 🖼️ | AI images | KIE + Replicate (FLUX, Imagen 4, Nano Banana Pro) |
| 🎬 | AI video clips, text-to-video and image-to-video | KIE + Replicate (Veo 3.1, Wan, Kling) |
| 👁️ | Video understanding: find scenes, objects, timestamps | TwelveLabs |
| 🔄 | AI review of your render, with fixes | TwelveLabs |
| 📝 | TikTok-style word-by-word captions | Whisper (local) + Remotion's official captions flow |
| 🎯 | Scene transitions: fade, slide, wipe, flip, clock-wipe | `@remotion/transitions` (official skills) |
| 📱 | 9:16 short-form pipeline for TikTok, Reels, Shorts | Built-in presets |
| 🎲 | 3D scenes and product showcases | `@remotion/three` (official skills) |
| 📊 | Animated charts, dashboards, counters | SVG + D3 |
| ✨ | Light leaks, film grain, vignettes, color grading, Lottie | `@remotion/effects` (official skills) |
| 🚀 | Render on PR or on demand | GitHub Actions |

## Commands

In Claude Code these are slash commands. In Codex, Gemini CLI and other agents they're skills with the same names: ask for one ("use the create-video skill") or just describe what you want.

| | Command | What it does |
|---|---|---|
| **Produce** | `/setup` | First-run wizard: dependencies, project, keys, MCP check |
| | `/create-video` | Full pipeline from a prompt to a rendered MP4 |
| | `/create-short` | 9:16 vertical video with a hook-first structure and captions |
| **Assets** | `/find-footage` | Search and download Pexels stock footage |
| | `/generate-image` | AI backgrounds, thumbnails, characters, art |
| | `/generate-clip` | AI clips from text or from a still image |
| **Audio** | `/add-voiceover` | Generate narration and wire it into the composition |
| | `/add-music` | Generate a track with fades and ducking |
| | `/transcribe` | Audio or video to text with word-level timestamps |
| **Polish** | `/add-captions` | Animated word-by-word captions |
| | `/add-transitions` | Professional scene transitions |
| **Analyze** | `/analyze-footage` | Understand existing footage with AI vision |
| | `/review-video` | Render, review, fix, repeat |

## How it works

```text
Your prompt → /create-video (or /create-short)
    │
    ├── 1. Studio     → Remotion Studio opens as soon as the project runs; watch it build
    ├── 2. Concept    → scenes, script, audio needs → you approve the plan
    ├── 3. Voiceover  → per-scene TTS (remotion-media / ElevenLabs), measured for timing
    ├── 4. Music      → background track (Suno via remotion-media)
    ├── 5. SFX        → hosted or generated sound effects
    ├── 6. Footage    → Pexels / AI images and clips / TwelveLabs analysis
    ├── 7. Visuals    → Remotion markup via the official skills: scenes, transitions, effects
    ├── 8. Captions   → word-level, TikTok-style
    ├── 9. Iterate    → tweak live in Studio
    ├── 10. Render    → when you ask: npx remotion render → MP4
    └── 11. Review    → /review-video → AI watches, suggests, iterates
```

## API keys

| Service | Variable | Needed? | Cost | Unlocks |
|---|---|---|---|---|
| [KIE](https://kie.ai) | `KIE_API_KEY` | ✅ Yes | Paid | Voiceover, music, SFX, images, video |
| [TwelveLabs](https://www.twelvelabs.io) | `TWELVELABS_API_KEY` | ✅ Yes | Free tier | Video analysis and review |
| [Pexels](https://www.pexels.com/api/) | `PEXELS_API_KEY` | Recommended | Free | Stock photos and videos |
| [ElevenLabs](https://elevenlabs.io) | `ELEVENLABS_API_KEY` | Optional | Free tier | Voice cloning, custom voices |
| [Replicate](https://replicate.com) | `REPLICATE_API_TOKEN` | Optional | Pay per use | 100+ image and video models |

Captions and transcription run locally with Whisper. Install `whisper-cpp` (`brew install whisper-cpp`) or OpenAI Whisper (`pip install openai-whisper`).

## MCP servers

The plugin configures 5 MCP servers for you:

- **remotion-media**: voiceover, music, SFX, images, video and subtitles in one server, backed by KIE and local Whisper.
- **TwelveLabs**: video understanding, scene analysis and review.
- **Pexels**: free stock footage and photos.
- **ElevenLabs** (optional): advanced voice features.
- **Replicate** (optional): 100+ image and video models.

## Troubleshooting

<details>
<summary><strong>The plugin shows "failed to load"</strong></summary>

You're on 2.1.0. Update to the [latest release](https://github.com/DojoCodingLabs/remotion-superpowers/releases/latest) (see Updating under [Install](#install)); 2.1.1 fixed the hooks schema.

</details>

<details>
<summary><strong>An MCP server won't connect</strong></summary>

- Check its key is set: `echo ${KIE_API_KEY:+set}`. In Gemini CLI, use `gemini extensions config` instead, because extensions don't see your shell environment.
- `uvx` servers (ElevenLabs, Pexels) need [uv](https://astral.sh/uv). `npx` servers need Node.js 18+.
- Restart your agent after changing keys. In Claude Code, `/mcp` shows each server's status.

</details>

<details>
<summary><strong>Pexels crashes on startup</strong></summary>

Known issue: `pexels-mcp-server` 0.0.4 is incompatible with `mcp` 2.x. The fix (`uvx --with "mcp[cli]<2" pexels-mcp-server`) is landing in [#10](https://github.com/DojoCodingLabs/remotion-superpowers/pull/10).

</details>

<details>
<summary><strong>Generated files end up in the wrong folder</strong></summary>

`remotion-media` writes to `public/` of the directory your agent was started from. Start it from the Remotion project root.

</details>

Still stuck? [Open an issue](https://github.com/DojoCodingLabs/remotion-superpowers/issues/new/choose). Search the existing ones first; there's a good chance someone has hit the same thing.

<details>
<summary><strong>Project structure</strong></summary>

```text
remotion-superpowers/
├── .claude-plugin/               # Claude Code plugin + marketplace manifests
├── .codex-plugin/plugin.json     # Codex plugin manifest
├── gemini-extension.json         # Gemini CLI extension manifest
├── .mcp.json                     # 5 MCP server configurations (shared)
├── skills/                       # 15 Agent Skills (SKILL.md, portable)
│   ├── setup/                    # setup wizard
│   ├── create-video/             # full video production from a prompt
│   ├── create-short/             # TikTok/Reels/Shorts
│   ├── find-footage/  generate-image/  generate-clip/
│   ├── add-voiceover/  add-music/  transcribe/
│   ├── add-captions/  add-transitions/
│   ├── analyze-footage/  review-video/
│   ├── remotion-production/      # media orchestration (17 rules), on top of Remotion's official skills
│   └── setup-guide/              # setup & troubleshooting knowledge
├── agents/                       # 3 Claude Code subagents
├── hooks/hooks.json              # Claude Code hooks (API key checks, tips)
├── scripts/                      # setup check, hook scripts, ci/validate.sh
├── CHANGELOG.md
└── README.md
```

</details>

## Star history

<a href="https://star-history.com/#DojoCodingLabs/remotion-superpowers&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=dojocodinglabs/remotion-superpowers&type=Date&theme=dark">
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=dojocodinglabs/remotion-superpowers&type=Date">
    <img alt="Star history chart" src="https://api.star-history.com/svg?repos=dojocodinglabs/remotion-superpowers&type=Date" width="100%">
  </picture>
</a>

If this saves you an afternoon of video editing, a ⭐ helps other builders find it.

## Contributors

<a href="https://github.com/DojoCodingLabs/remotion-superpowers/graphs/contributors">
  <img alt="Contributors" src="https://contrib.rocks/image?repo=DojoCodingLabs/remotion-superpowers">
</a>

Thanks to everyone who has sent a fix, filed a sharp bug report, or forked this to build something of their own. New here? Read [CONTRIBUTING.md](CONTRIBUTING.md). Better prompt flows, new production rules, and support for more agents are all welcome.

See [CHANGELOG.md](CHANGELOG.md) for what changed in each release.

## Built by Dojo Coding

[Dojo Coding](https://dojocoding.io) is a LATAM-first tech education ecosystem. We build tools for developers and teach people to code.

**More from Dojo Coding:** [CodeSensei](https://github.com/DojoCodingLabs/code-sensei) (learn to code while you vibecode) · [juan-workflow](https://github.com/DojoCodingLabs/juan-workflow) (dev lifecycle guardrails) · [VibeCoding Bootcamp](https://dojocoding.io) (structured curriculum with live mentors)

Free forever. Open source. [MIT licensed](LICENSE).

<p align="center">
  <a href="https://dojocoding.io"><img src="docs/assets/dojocoding-mark.png" alt="Dojo Coding" width="48"></a>
</p>
