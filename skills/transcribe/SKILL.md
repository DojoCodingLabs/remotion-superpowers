---
name: transcribe
description: Transcribe audio or video files to text with timestamps. Two routes, line-level SRT via the generate_subtitles MCP tool or word-level Caption JSON via the official remotion-captions flow, plus plain text, for use with Remotion's captions system.
---

# Transcribe: Audio/Video to Text

You are helping the user transcribe audio or video files into text with precise timestamps.

## Workflow

### 1. Identify the Source File

Find audio/video files to transcribe:

```bash
ls public/ public/footage/ 2>/dev/null | grep -E '\.(mp3|wav|m4a|ogg|mp4|mov|webm)$'
```

Ask the user which file to transcribe if multiple exist. Transcribe each source file separately, and keep its timestamps relative to the start of that file.

### 2. Pick the Route

Ask what the transcript is for:

| Need | Route | Granularity |
|---|---|---|
| SRT file, YouTube-style line captions, a quick readable transcript | **A. `generate_subtitles`** (MCP, local Whisper) | One entry per subtitle line |
| Word-by-word captions (TikTok, karaoke), syncing animations to specific words | **B. Official word-level flow** (`remotion-captions`) | One entry per word |

#### Route A: SRT via generate_subtitles

```
Use remotion-media generate_subtitles:
- input_file: [audio/video filename inside public/, e.g. vo-scene1.mp3]
- output_name: [optional, defaults to the input filename]
- language: [optional, e.g. en, es; auto-detects if omitted]
- model: [optional: tiny | base | small | medium | large; default base]
```

This needs whisper-cpp (`brew install whisper-cpp`) or OpenAI Whisper (`pip install openai-whisper`) installed locally. It saves an SRT file in `public/` of the directory your agent was launched from, so start your agent (Claude Code, Codex, Gemini CLI…) from the Remotion project root.

SRT is **line-level**. To use it in Remotion, convert it with `parseSrt()` from `@remotion/captions`, following official `remotion-captions/import-srt-captions.md`. Each resulting `Caption` is a whole line, not a word.

#### Route B: Word-level JSON via the official flow

Follow official `remotion-captions/transcribe-captions.md`. It writes a Node script using `@remotion/whisper-webgpu` (`downloadWhisperModel`, `loadWhisperModel`, `transcribe`, then `toCaptions({ whisperWebGpuOutput })`) that saves `Caption` JSON. `small.en` is the default model for English; for other languages use a multilingual model and pass `language`. It needs a compatible GPU and doesn't run on Linux arm64. If it can't run, fall back to Route A and tell the user the result is line-level.

### 3. Present the Transcript

Show the transcription with timestamps:

```
📝 Transcription: [filename]

[00:00:00 → 00:00:03] Welcome to our product demo
[00:00:03 → 00:00:07] Today we're going to show you how easy it is
[00:00:07 → 00:00:11] to create professional videos with code
...

Total duration: [X]s
Word count: [X] words
```

### 4. Output Formats

Deliver what the user asked for:

**SRT** (Route A): standard subtitle format:
```srt
1
00:00:00,000 --> 00:00:03,200
Welcome to our product demo

2
00:00:03,200 --> 00:00:07,100
Today we're going to show you how easy it is
```

**JSON Captions** (Route B, or Route A through `parseSrt()` for line-level): the `Caption` type from `@remotion/captions`. Every entry needs `timestampMs` and `confidence` (either may be `null`), and each word starts with a space:
```json
[
  { "text": " Welcome", "startMs": 0, "endMs": 800, "timestampMs": 400, "confidence": 0.95 },
  { "text": " to", "startMs": 800, "endMs": 1000, "timestampMs": 900, "confidence": 0.98 },
  { "text": " our", "startMs": 1000, "endMs": 1200, "timestampMs": 1100, "confidence": 0.97 }
]
```

**Plain text**: just the words, no timestamps:
```
Welcome to our product demo. Today we're going to show you how easy it is to create professional videos with code.
```

### 5. Common Use Cases

After transcription, suggest next steps:

- **Add captions** → Run `/add-captions` (word-level JSON for TikTok/karaoke styles; SRT is enough for YouTube style)
- **Sync animations** → Use word-level timestamps (Route B) to trigger visual elements at specific words
- **Create a script** → Edit the transcript as the basis for a new voiceover
- **Translate** → Use the transcript to create versions in other languages
- **Content repurpose** → Extract key quotes for social media clips

Both routes run entirely on-device, with no API key needed.
