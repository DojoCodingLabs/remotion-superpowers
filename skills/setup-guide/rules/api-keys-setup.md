# API Keys Setup — Detailed Guide

| # | Service | Variable | Needed? | Powers |
|---|---|---|---|---|
| 1 | ElevenLabs | `ELEVENLABS_API_KEY` | Required | Voiceover, sound effects, music, word-level transcription fallback |
| 2 | KIE | `KIE_API_KEY` | Required | AI images and clips (remotion-media); optional audio drafts |
| 3 | TwelveLabs | `TWELVELABS_API_KEY` | Required | Footage analysis and AI review of renders |
| 4 | Pexels | `PEXELS_API_KEY` | Recommended | Free stock photos and videos |
| 5 | Replicate | `REPLICATE_API_TOKEN` | Optional | Specific image/video models; fallback when a KIE clip fails |

In Claude Code and Codex, export the keys in the shell you start the agent from. In Gemini CLI, set them with `gemini extensions config remotion-superpowers "<setting name>"`; extensions don't see your shell environment.

---

## 1. ElevenLabs API Key (Required)

**What it provides:** Voiceovers (`eleven_v4`), sound effects, and music (`music_v2_5`; Eleven Music is cleared for commercial use on paid plans), generated through the official ElevenLabs skills (`npx skills add elevenlabs/skills`). Also word-level transcription (Scribe) for captions when there's no GPU for local Whisper.

**How to get it:** the quickest way is `npx -y @elevenlabs/cli@latest onboard init` from the project folder: it signs you in and stores a key for the project. By hand: https://elevenlabs.io → API keys page → create a key.

```bash
export ELEVENLABS_API_KEY=your-key-here
echo 'export ELEVENLABS_API_KEY=your-key-here' >> ~/.zshrc
```

**Pricing:** free tier available; a paid plan is needed for commercial music. If a key stops working, the official `setup-api-key` skill walks through fixing it.

---

## 2. KIE API Key (Required for AI images and clips)

**What it provides:** AI images (Nano Banana Pro) and AI video clips (Veo 3.1) through the `remotion-media` server. It can also make cheap audio drafts (`generate_speech`, `generate_music`, `generate_sound_effect`).

> KIE is an aggregator that resells other companies' models (Suno, Veo, ElevenLabs) without claiming their owners' authorization. Use KIE audio for drafts and internal work only, and generate final commercial audio with ElevenLabs.

**How to get it:** https://kie.ai → create an account → copy the API key from the dashboard.

```bash
export KIE_API_KEY=your-key-here
echo 'export KIE_API_KEY=your-key-here' >> ~/.zshrc
```

**Pricing:** pay as you go, in credits. KIE deletes generated files after 14 days, so keep your copies in `public/`.

---

## 3. TwelveLabs API Key (Required)

**What it provides:** video understanding. Upload a file as an asset, then analyse it with Pegasus to describe footage, pick the best moments, or review your rendered video and return fixes. Indexed libraries add search ("find the moment where…").

**How to get it:** https://www.twelvelabs.io → sign up → dashboard → API keys.

```bash
export TWELVELABS_API_KEY=your-key-here
echo 'export TWELVELABS_API_KEY=your-key-here' >> ~/.zshrc
```

**Pricing:** free tier with limited storage; paid plans for more. Agent docs: https://docs.twelvelabs.io.

---

## 4. Pexels API Key (Recommended — Free)

**What it provides:** search and download free stock photos and videos in HD/4K.

**How to get it:** https://www.pexels.com/api/ → "Your API Key" → sign in. The key is shown immediately.

```bash
export PEXELS_API_KEY=your-key-here
echo 'export PEXELS_API_KEY=your-key-here' >> ~/.zshrc
```

**Pricing:** free; 200 requests per hour, 20,000 per month.

**Attribution:** Pexels doesn't require attribution, but it's appreciated. The Pexels terms ban bulk or systematic downloading and using the content to train ML models.

---

## 5. Replicate API Token (Optional)

**What it provides:** hundreds of image and video models (FLUX.2, Nano Banana Pro, Kling, Seedance, Wan, and more) through the official local `replicate-mcp` server, guided by the official Replicate skills (`npx skills add replicate/skills`). Use it for a specific model, or when a KIE clip fails.

**How to get it:** https://replicate.com → account → API tokens.

```bash
export REPLICATE_API_TOKEN=your-token-here
echo 'export REPLICATE_API_TOKEN=your-token-here' >> ~/.zshrc
```

**Pricing:** pay per prediction; varies by model.

---

## Troubleshooting

### MCP server won't connect
- Verify the key is set: `echo ${VARIABLE_NAME:+set}`
- Restart your agent after setting environment variables
- For `npx` servers (remotion-media, TwelveLabs, Pexels, Replicate): Node.js 22.18 or newer
- For the deprecated ElevenLabs MCP server (`uvx`): install uv (`curl -LsSf https://astral.sh/uv/install.sh | sh`)

### "spawn uvx ENOENT" error
The system can't find `uvx`. Get its full path with `which uvx`. If it returns something like `/Users/you/.local/bin/uvx`, the MCP config may need that full path instead of `uvx`.

### Keys set but not working
- Run `source ~/.zshrc` after adding the export, or open a new terminal
- Check for extra spaces or quotes in the key
- Confirm the key is active in the service's dashboard; some take a few minutes to activate
