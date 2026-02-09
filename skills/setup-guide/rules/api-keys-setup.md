# API Keys Setup — Detailed Guide

## 1. KIE API Key (PRIMARY — Required)

**What it provides:** Single key for music generation (Suno), sound effects (ElevenLabs SFX), text-to-speech (ElevenLabs TTS), image generation (Nano Banana Pro), video generation (Veo 3.1), and subtitle generation (Whisper).

**How to get it:**
1. Go to https://kie.ai
2. Create an account
3. Navigate to your dashboard
4. Copy your API key

**Environment variable:** `KIE_API_KEY`

**Set it:**
```bash
export KIE_API_KEY=your-key-here
echo 'export KIE_API_KEY=your-key-here' >> ~/.zshrc
```

**Pricing:** Paid service — check kie.ai for current pricing. Each media generation operation consumes credits.

---

## 2. TwelveLabs API Key (Required)

**What it provides:** Video understanding — index videos, semantic search within video content, scene detection, object recognition, speaker identification, video summarization. This is the "eyes" of the plugin.

**How to get it:**
1. Go to https://www.twelvelabs.io
2. Sign up for an account
3. Go to your dashboard → API Keys
4. Create and copy your API key

**Environment variable:** `TWELVELABS_API_KEY`

**Set it:**
```bash
export TWELVELABS_API_KEY=your-key-here
echo 'export TWELVELABS_API_KEY=your-key-here' >> ~/.zshrc
```

**Pricing:** Free tier available with limited indexing minutes. Paid plans for higher volume.

---

## 3. Pexels API Key (Recommended — Free)

**What it provides:** Search and download free, royalty-free stock photos and videos. High-quality HD/4K content.

**How to get it:**
1. Go to https://www.pexels.com/api/
2. Click "Get Started" or "Your API Key"
3. Create an account (or sign in)
4. Your API key is displayed immediately

**Environment variable:** `PEXELS_API_KEY`

**Set it:**
```bash
export PEXELS_API_KEY=your-key-here
echo 'export PEXELS_API_KEY=your-key-here' >> ~/.zshrc
```

**Pricing:** Completely free. 200 requests per hour, 20,000 per month.

**Attribution requirement:** Must credit Pexels and photographers when using their content.

---

## 4. ElevenLabs API Key (Optional)

**What it provides:** Direct access to the full ElevenLabs platform — voice cloning, custom voice creation, advanced TTS controls, audio isolation, transcription. The basic TTS and SFX are already available through KIE, so this is only needed for advanced voice features.

**When you need this:**
- You want to clone your own voice or a specific voice
- You need fine control over voice parameters (stability, similarity boost, style)
- You want to use ElevenLabs' voice library directly
- You need audio isolation (separate voice from background)

**How to get it:**
1. Go to https://elevenlabs.io
2. Sign up for an account
3. Go to Profile → API Keys
4. Copy your API key

**Environment variable:** `ELEVENLABS_API_KEY`

**Set it:**
```bash
export ELEVENLABS_API_KEY=your-key-here
echo 'export ELEVENLABS_API_KEY=your-key-here' >> ~/.zshrc
```

**Pricing:** Free tier with 10,000 characters/month. Paid plans for more.

---

## Troubleshooting

### MCP server won't connect
- Verify the API key is set: `echo $VARIABLE_NAME`
- Restart Claude Code after setting environment variables
- For `uvx` commands: ensure `uv` is installed (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- For `npx` commands: ensure Node.js >= 18 is installed

### "spawn uvx ENOENT" error
The system can't find `uvx`. Get its full path:
```bash
which uvx
```
If it returns a path like `/Users/you/.local/bin/uvx`, the `.mcp.json` may need the full path instead of just `uvx`.

### Keys set but not working
- Make sure you ran `source ~/.zshrc` after adding the export
- Check for extra spaces or quotes in the key
- Verify the key is active on the service's dashboard
- Some services take a few minutes to activate new keys
