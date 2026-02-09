---
name: setup
description: First-run setup wizard for Remotion Superpowers. Checks dependencies, installs Remotion skills, walks through API key configuration, and verifies MCP server connections.
---

# Remotion Superpowers — Setup Wizard

You are running the setup wizard for the Remotion Superpowers plugin. Follow these steps carefully and guide the user through each one.

## Step 1: Check System Dependencies

Run these checks and report results:

```bash
node --version
npm --version
python3 --version 2>/dev/null || python --version 2>/dev/null
which uvx 2>/dev/null || echo "uvx not found"
```

**Required:**
- Node.js >= 18 (needed for Remotion and MCP servers)
- npm (comes with Node.js)

**Recommended:**
- Python 3 + `uv`/`uvx` (needed for ElevenLabs and Pexels MCP servers)
  - If missing, tell user: `curl -LsSf https://astral.sh/uv/install.sh | sh`

Report each as ✓ or ✗ with version.

## Step 2: Check Remotion Project

Check if the current directory has a `remotion.config.ts` or `remotion.config.js` file.

**If YES:** Tell the user their Remotion project was detected.

**If NO:** Ask the user if they want to:
- Create a new Remotion project here: `npx create-video@latest`
  - Recommend: Blank template, yes to TailwindCSS, yes to install Skills
- Or navigate to an existing Remotion project first

Do NOT proceed until the user is in a Remotion project directory.

## Step 3: Install Remotion Agent Skills

Check if `.claude/skills/remotion-best-practices/` exists.

**If not installed:**
```bash
npx skills add remotion-dev/skills
```

Tell the user: "Remotion best practices skills installed. Claude now knows Remotion's APIs, animation patterns, audio handling, and more."

## Step 4: Configure API Keys

Walk the user through each API key. For each one:
1. Explain what the service provides
2. Give the signup URL
3. Tell them the environment variable name
4. Ask them to set it: `export VAR_NAME=their-key`
5. Recommend adding to `~/.zshrc` or `~/.bashrc` for persistence

### 4a. KIE API Key (PRIMARY — covers Suno + ElevenLabs + more)
- **What:** Single API key that provides music generation (Suno), sound effects (ElevenLabs SFX), text-to-speech (ElevenLabs TTS), image generation, video generation, and subtitle generation.
- **Signup:** https://kie.ai — create account, get API key from dashboard
- **Variable:** `KIE_API_KEY`
- **Command:** `export KIE_API_KEY=your-key-here`
- **Persistence:** `echo 'export KIE_API_KEY=your-key-here' >> ~/.zshrc`

### 4b. TwelveLabs API Key (VIDEO UNDERSTANDING — "eyes")
- **What:** Gives Claude the ability to "see" video files — analyze footage, find specific scenes, detect objects and speakers, generate summaries. This is how the plugin understands existing video in your project folders.
- **Signup:** https://www.twelvelabs.io — create account, get API key from dashboard
- **Variable:** `TWELVELABS_API_KEY`
- **Command:** `export TWELVELABS_API_KEY=your-key-here`
- **Persistence:** `echo 'export TWELVELABS_API_KEY=your-key-here' >> ~/.zshrc`

### 4c. Pexels API Key (FREE STOCK FOOTAGE)
- **What:** Free stock photos and videos. Search by keyword, download HD/4K clips directly into your project.
- **Signup:** https://www.pexels.com/api/ — completely free, create account and get key instantly
- **Variable:** `PEXELS_API_KEY`
- **Command:** `export PEXELS_API_KEY=your-key-here`
- **Persistence:** `echo 'export PEXELS_API_KEY=your-key-here' >> ~/.zshrc`

### 4d. ElevenLabs API Key (OPTIONAL — advanced voice features)
- **What:** Direct access to the full ElevenLabs platform — voice cloning, custom voices, advanced TTS controls, audio isolation. The basic TTS/SFX is already covered by KIE, but this gives you premium voice features.
- **Signup:** https://elevenlabs.io — free tier with 10k credits/month
- **Variable:** `ELEVENLABS_API_KEY`
- **Command:** `export ELEVENLABS_API_KEY=your-key-here`
- **Persistence:** `echo 'export ELEVENLABS_API_KEY=your-key-here' >> ~/.zshrc`
- **Note:** This is optional. Skip if you don't need voice cloning or custom voices.

After each key, ask the user to confirm they've set it before moving to the next one. It's OK to skip optional ones.

## Step 5: Reload Shell & Verify

Tell the user to reload their shell:
```bash
source ~/.zshrc
```

Then verify the environment variables are set:
```bash
echo "KIE_API_KEY: ${KIE_API_KEY:+SET}" 
echo "TWELVELABS_API_KEY: ${TWELVELABS_API_KEY:+SET}"
echo "PEXELS_API_KEY: ${PEXELS_API_KEY:+SET}"
echo "ELEVENLABS_API_KEY: ${ELEVENLABS_API_KEY:+SET}"
```

## Step 6: Verify MCP Connections

Tell the user to check MCP server status:
```
/mcp
```

All configured servers should show as connected. If any fail:
- Check that the API key environment variable is set
- For `uvx`-based servers, ensure `uv` is installed
- For `npx`-based servers, ensure Node.js is installed
- Try restarting Claude Code

## Step 7: Setup Complete

Print a summary:

```
🎬 Remotion Superpowers — Setup Complete!

✓ Dependencies verified
✓ Remotion project detected
✓ Remotion skills installed
✓ API keys configured
✓ MCP servers connected

Available commands:
  /create-video     — Full video production from a prompt
  /find-footage     — Search & download stock footage from Pexels
  /analyze-footage  — Analyze existing video files with AI vision
  /add-voiceover    — Generate and add narration to your video
  /add-music        — Generate and add background music

Try it: "Create a 30-second product demo video for a todo app"
```
