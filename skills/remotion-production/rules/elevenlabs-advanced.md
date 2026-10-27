# ElevenLabs Advanced — Voice Cloning & Custom TTS

## Overview

The ElevenLabs MCP server provides advanced voice features beyond basic TTS: voice cloning, custom voice parameters, voice library browsing, and audio isolation. Use this when you need more control than remotion-media's `generate_speech` provides.

## Output Location (read first)

ElevenLabs MCP tools that write files (`text_to_speech`, `isolate_audio`, …) save to `~/Desktop` unless you pass `output_directory`. **Always set `output_directory` to the absolute path of the project's `public/` folder**, e.g. `"/path/to/project/public"`. The tools pick their own filenames, so rename the result to the project convention right after (`mv public/<returned-name>.mp3 public/vo-scene1.mp3`).

## When to Use ElevenLabs MCP vs remotion-media

| Scenario | Use | Why |
|---|---|---|
| Basic narration, any of the 21 built-in voices | remotion-media `generate_speech` | Simpler, saves straight to `public/`, no ElevenLabs key |
| Specific ElevenLabs voice ID | ElevenLabs MCP | Direct voice selection |
| Voice cloning from sample | ElevenLabs MCP | Only way to clone voices |
| `style`, speaker boost, `eleven_v3` model | ElevenLabs MCP | `generate_speech` exposes only stability, similarity and speed |
| Multiple voices in one script | ElevenLabs MCP | Per-line voice switching |
| Voice library browsing | ElevenLabs MCP | Your voices (`search_voices`) or community voices (`search_voice_library`) |
| Audio isolation | ElevenLabs MCP | Extract voice from noisy audio |

## Voice Cloning Workflow

### 1. Prepare Audio Sample

Requirements for good clones:
- **Duration**: 30 seconds to 3 minutes of clean speech
- **Quality**: Clear recording, minimal background noise
- **Content**: Natural speaking (not reading, not whispering)
- **Format**: MP3 or WAV

### 2. Create the Clone

```
Use ElevenLabs voice_clone:
  name: "Brand Voice"
  files: ["/path/to/sample.mp3"]
  description: "Company brand narrator voice"
```

It returns the new voice's ID. Cloning costs credits: only run it when the user asks.

### 3. Generate with Cloned Voice

```
Use ElevenLabs text_to_speech:
  text: "Welcome to our product demo."   # one scene per call
  voice_id: "[returned_voice_id]"
  model_id: "eleven_multilingual_v2"
  output_directory: "/absolute/path/to/project/public"
```

### 4. Wire into the Remotion Project

Rename the file to `public/vo-scene1.mp3` (and so on per scene). From here it's the same as a `generate_speech` file: measure it in `calculateMetadata` and place it with `<Audio>` from `@remotion/media`, as in `voiceover-sync.md`.

## TTS Parameters

### Stability (0.0 – 1.0)

Controls consistency vs expressiveness:
- **0.0–0.3**: Very expressive, varies between generations, emotional
- **0.3–0.6**: Balanced expressiveness with consistency
- **0.6–0.8**: Stable, predictable, professional (recommended default)
- **0.8–1.0**: Very stable, monotone, robotic

### Similarity Boost (0.0 – 1.0)

How closely to match the original voice:
- **0.0–0.3**: Loose match, more model creativity
- **0.5–0.7**: Good balance (recommended)
- **0.8–1.0**: Very close match, but may amplify artifacts

### Style (0.0 – 1.0)

Amplifies the voice's speaking style:
- **0.0**: Neutral delivery
- **0.2–0.5**: Moderate style (recommended)
- **0.5+**: Strong stylistic expression, may reduce stability

### Speed (0.7 – 1.2)

Both ElevenLabs `text_to_speech` and remotion-media `generate_speech` accept 0.7–1.2; extreme values can hurt quality.
- **0.7–0.8**: Slow, deliberate (good for explainers)
- **1.0**: Normal speed (default)
- **1.1–1.2**: Slightly faster (good for social media)

### Recommended Presets

| Video Type | Stability | Similarity | Style | Speed |
|---|---|---|---|---|
| Corporate narration | 0.7 | 0.6 | 0.2 | 1.0 |
| Conversational/social | 0.4 | 0.5 | 0.4 | 1.1 |
| Documentary | 0.6 | 0.7 | 0.3 | 0.9 |
| Energetic promo | 0.3 | 0.5 | 0.5 | 1.2 |
| Calm meditation/ASMR | 0.8 | 0.6 | 0.1 | 0.8 |

## Multi-Voice Scripts

For videos with multiple speakers (interviews, dialogues, characters):

1. Generate one file per line with that speaker's voice: `vo-line01-narrator`, `vo-line02-interviewer`, `vo-line03-guest`, … (built-in voices via `generate_speech`, cloned or library voices via `text_to_speech` with `output_directory` set to `public/`).
2. Measure every line in `calculateMetadata` and compute each line's start frame as the running sum of the previous lines (plus a small gap), exactly like the per-scene pattern in `voiceover-sync.md`.
3. Place each line with `<Audio>` from `@remotion/media`, with `from` set to its start frame directly on the `<Audio>` (official `remotion-markup` audio.md, "Delaying").

Keep a table of speaker → voice ID in the project so lines can be regenerated consistently.

## Voice Library

Find a voice, then pass its ID to `text_to_speech`:

```
Use ElevenLabs search_voices:          # voices already in the user's account
  search: "narrator"

Use ElevenLabs search_voice_library:   # the shared community library
  search: "deep british documentary"
  page_size: 10
```

Both return voices with their IDs, names, and descriptions. Put the filter in the `search` text, e.g.:
- **Category**: narration, conversational, characters, news
- **Language**: English, Spanish, French, etc.
- **Gender**: male, female
- **Age**: young, middle-aged, old

## Audio Isolation

Extract clean voice from noisy recordings:

```
Use ElevenLabs isolate_audio:
  input_file_path: "/absolute/path/to/noisy-sample.mp3"   # a local file, not a URL
  output_directory: "/absolute/path/to/project/public"
```

Rename the result to the project convention (e.g. `vo-sample-clean.mp3`).

Useful when:
- User provides a reference voice sample with background noise
- Cleaning up recorded narration before using in Remotion
- Extracting dialogue from video clips

## Best Practices

1. **Start with remotion-media** for basic narration — it's simpler
2. **Use ElevenLabs MCP** when you need voice cloning, custom params, or multi-voice
3. **Test voice clones with short text first** before generating full narration
4. **Keep stability at 0.5-0.7** for professional narration
5. **Always pass `output_directory`** — otherwise files land on `~/Desktop`, outside the project
6. **Generate one sentence at a time** for multi-voice scripts, then sequence in Remotion
7. **Save voice IDs** — note which voice ID was used so you can regenerate consistently
8. **Respect voice cloning ethics** — only clone voices you have permission to use
9. **Use `eleven_multilingual_v2`** model for best quality across languages
