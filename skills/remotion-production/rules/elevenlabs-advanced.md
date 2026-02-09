# ElevenLabs Advanced — Voice Cloning & Custom TTS

## Overview

The ElevenLabs MCP server provides advanced voice features beyond basic TTS: voice cloning, custom voice parameters, voice library browsing, and audio isolation. Use this when you need more control than remotion-media's `generate_tts` provides.

## When to Use ElevenLabs MCP vs remotion-media

| Scenario | Use | Why |
|---|---|---|
| Basic narration, any voice | remotion-media `generate_tts` | Simpler, auto-saves to project |
| Specific ElevenLabs voice ID | ElevenLabs MCP | Direct voice selection |
| Voice cloning from sample | ElevenLabs MCP | Only way to clone voices |
| Custom stability/style params | ElevenLabs MCP | Fine-tuned control |
| Multiple voices in one script | ElevenLabs MCP | Per-line voice switching |
| Voice library browsing | ElevenLabs MCP | Discover community voices |
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
Use ElevenLabs add_voice:
  name: "Brand Voice"
  files: ["/path/to/sample.mp3"]
  description: "Company brand narrator voice"
```

### 3. Generate with Cloned Voice

```
Use ElevenLabs text_to_speech:
  text: "Welcome to our product demo."
  voice_id: "[returned_voice_id]"
  model_id: "eleven_multilingual_v2"
```

### 4. Save to Remotion Project

Download the generated audio to your project's `public/audio/` directory, then reference it:

```tsx
<Audio src={staticFile("audio/brand-narration.mp3")} volume={1.0} />
```

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

### Speed (0.5 – 2.0)

- **0.7–0.8**: Slow, deliberate (good for explainers)
- **1.0**: Normal speed (default)
- **1.2–1.3**: Slightly faster (good for social media)

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

```tsx
// Generate each voice separately
// Voice A: narrator
// Voice B: interviewer
// Voice C: interviewee

<>
  <Sequence from={0} durationInFrames={3 * fps}>
    <Audio src={staticFile("audio/narrator-intro.mp3")} volume={1.0} />
  </Sequence>

  <Sequence from={3 * fps} durationInFrames={4 * fps}>
    <Audio src={staticFile("audio/interviewer-q1.mp3")} volume={1.0} />
  </Sequence>

  <Sequence from={7 * fps} durationInFrames={6 * fps}>
    <Audio src={staticFile("audio/interviewee-a1.mp3")} volume={1.0} />
  </Sequence>
</>
```

Generate each line with its corresponding voice ID, then sequence them in Remotion.

## Voice Library

Browse and use community-created voices:

```
Use ElevenLabs get_voices
```

This returns available voices with their IDs, names, and descriptions. Filter by:
- **Category**: narration, conversational, characters, news
- **Language**: English, Spanish, French, etc.
- **Gender**: male, female
- **Age**: young, middle-aged, old

## Audio Isolation

Extract clean voice from noisy recordings:

```
Use ElevenLabs audio_isolation:
  audio_url: "[url_to_noisy_audio]"
```

Useful when:
- User provides a reference voice sample with background noise
- Cleaning up recorded narration before using in Remotion
- Extracting dialogue from video clips

## Best Practices

1. **Start with remotion-media** for basic narration — it's simpler
2. **Use ElevenLabs MCP** when you need voice cloning, custom params, or multi-voice
3. **Test voice clones with short text first** before generating full narration
4. **Keep stability at 0.5-0.7** for professional narration
5. **Generate one sentence at a time** for multi-voice scripts, then sequence in Remotion
6. **Save voice IDs** — note which voice ID was used so you can regenerate consistently
7. **Respect voice cloning ethics** — only clone voices you have permission to use
8. **Use `eleven_multilingual_v2`** model for best quality across languages
