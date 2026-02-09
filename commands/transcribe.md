---
name: transcribe
description: Transcribe audio or video files to text with word-level timestamps. Uses Whisper for accurate transcription, outputs SRT subtitles or JSON captions for use with Remotion's captions system.
---

# Transcribe — Audio/Video to Text

You are helping the user transcribe audio or video files into text with precise timestamps.

## Workflow

### 1. Identify the Source File

Find audio/video files to transcribe:

```bash
# Check common locations
ls public/audio/ public/footage/ public/ 2>/dev/null | grep -E '\.(mp3|wav|m4a|ogg|mp4|mov|webm)$'
```

Ask the user which file to transcribe if multiple exist.

### 2. Transcribe with Whisper

```
Use remotion-media generate_subtitles:
- input: [path to audio/video file]
- project_path: [project root path]
```

This generates an SRT file with timestamps saved to the project.

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

Ask what format the user needs:

**SRT (default)** — Standard subtitle format:
```srt
1
00:00:00,000 --> 00:00:03,200
Welcome to our product demo

2
00:00:03,200 --> 00:00:07,100
Today we're going to show you how easy it is
```

**JSON Captions** — For Remotion's `@remotion/captions`:
```json
[
  { "text": " Welcome", "startMs": 0, "endMs": 800, "confidence": 0.95 },
  { "text": " to", "startMs": 800, "endMs": 1000, "confidence": 0.98 },
  { "text": " our", "startMs": 1000, "endMs": 1200, "confidence": 0.97 }
]
```

**Plain text** — Just the words, no timestamps:
```
Welcome to our product demo. Today we're going to show you how easy it is to create professional videos with code.
```

### 5. Common Use Cases

After transcription, suggest next steps:

- **Add captions** → Run `/add-captions` to create TikTok-style animated subtitles
- **Sync animations** → Use timestamps to trigger visual elements at specific words
- **Create a script** → Edit the transcript as the basis for a new voiceover
- **Translate** → Use the transcript to create versions in other languages
- **Content repurpose** → Extract key quotes for social media clips

### 6. Alternative: Local Whisper

If the user wants to avoid API calls, Remotion has built-in Whisper support:

```bash
# Install Whisper.cpp locally
npx remotion add @remotion/install-whisper-cpp
```

```typescript
import { installWhisperCpp, transcribe } from "@remotion/install-whisper-cpp";

// One-time install
await installWhisperCpp({ version: "1.5.5" });

// Transcribe
const result = await transcribe({
  inputPath: "public/audio/voiceover.mp3",
  whisperPath: ".whisper",
  model: "medium.en",
  tokenLevelTimestamps: true,
});
```

This runs entirely on-device — no API key needed.
