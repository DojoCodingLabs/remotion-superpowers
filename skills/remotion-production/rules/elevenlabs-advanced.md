# ElevenLabs Advanced — Voice Cloning & Custom TTS

## Overview

Beyond basic narration, ElevenLabs gives you voice cloning, the voice library, voice changing, audio isolation and multi-voice scripts. Do this work with the official ElevenLabs skills (`npx skills add elevenlabs/skills`) and the `@elevenlabs/elevenlabs-js` SDK, in the same project script as `audio-integration.md` or a one-off script next to it:

| Task | Official skill |
|---|---|
| Pick a voice, tune it, generate speech | `text-to-speech` |
| Clean a noisy sample or recording | `voice-isolator` |
| Re-voice an existing recording (keep the performance, swap the speaker) | `voice-changer` |
| Clone a voice from a sample | No dedicated skill: SDK `voices.ivc.create` (below) |
| Key missing or rejected | `setup-api-key` |

This rule adds where the files go, what they're called, and the presets. The official skills win on any API detail.

## Files In and Out

- **Inputs** (voice samples, noisy recordings) go in `public/` too, e.g. `public/sample-brand-voice.mp3`. Read them with `createReadStream("public/…")`.
- **Outputs** go to the `public/` root with our names: `vo-…` for speech, `vo-…-clean` for isolated audio. Never overwrite the original; save the processed file under a new name.
- **The deprecated ElevenLabs MCP** (`elevenlabs-mcp` 0.12.2, archived upstream, shipped for one more release as an interactive alternative) runs with base path `./public`. It **only reads and writes inside `public/`**, so put input files there first and pass their absolute path. For output, leave `output_directory` out (it defaults to `public/`) or pass the absolute path of the project's `public/`; a relative `"public"` nests into `public/public/`. It picks its own filenames, so rename the result right after (`mv public/<returned-name>.mp3 public/vo-scene1.mp3`).

## When to Use What

| Scenario | Use | Why |
|---|---|---|
| Narration with a pre-made or library voice | Script (`text-to-speech`) | The default path; see `voiceover-sync.md` |
| Voice cloning from a sample | SDK `voices.ivc.create`, or MCP `voice_clone` | Gives you a `voice_id` to use like any other |
| Re-voice a scratch recording | `voice-changer` | Keeps timing and emotion, swaps the voice |
| Multiple voices in one script | Script, one entry per line | Per-line voice switching |
| Voice library browsing | SDK `voices.search` / `voices.getShared`, or MCP `search_voices` / `search_voice_library` | Your voices or the shared community library |
| Audio isolation | `voice-isolator`, or MCP `isolate_audio` | Extract voice from noisy audio |
| Cheap drafts with a built-in voice | KIE `generate_speech` | Drafts only: Suno and the other KIE-resold models aren't licensed by their owners through KIE. Use KIE audio for drafts and internal work, and generate final commercial audio with ElevenLabs. |

## Voice Cloning Workflow

### 1. Prepare Audio Sample

Requirements for good clones:
- **Duration**: 30 seconds to 3 minutes of clean speech
- **Quality**: Clear recording, minimal background noise (run it through `voice-isolator` first if needed)
- **Content**: Natural speaking (not reading, not whispering)
- **Format**: MP3 or WAV, saved in `public/`

### 2. Create the Clone

Instant voice cloning with the SDK:

```ts
import { ElevenLabsClient } from "@elevenlabs/elevenlabs-js";
import { createReadStream } from "node:fs";

const client = new ElevenLabsClient();
const { voiceId } = await client.voices.ivc.create({
  name: "Brand Voice",
  files: [createReadStream("public/sample-brand-voice.mp3")],
  removeBackgroundNoise: true,
});
console.log(voiceId);
```

Cloning costs credits: only run it when the user asks, and only for a voice they have permission to use. Deprecated MCP alternative: `voice_clone` with `name`, `files` (absolute paths inside `public/`) and `description`.

### 3. Generate with the Cloned Voice

Set `VOICE_ID` in `scripts/generate-audio.ts` to the new ID and run it. `eleven_v4` is the default model and the official skill rates it highest for cloning accuracy.

### 4. Wire into the Remotion Project

The files are `public/vo-scene1.mp3` and so on, so from here it's the same as any voiceover: measure them in `calculateMetadata` and place them with `<Audio>` from `@remotion/media`, as in `voiceover-sync.md`.

## TTS Parameters

**`eleven_v4` (default) takes only `stability` and `similarity_boost`.** It has no `style` or `speed` and no SSML: steer delivery with audio tags (`[excited]`, `[whispers]`, `[sighs]`) and punctuation (ellipses for pauses, capitals for emphasis). `style` and `speed` exist only on the older models (`eleven_multilingual_v2`, `eleven_v3`). Pass settings as `voiceSettings` in the `convert()` call, as the official `text-to-speech` skill shows.

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

### Style and Speed (older models only)

- **Style** (0.0–1.0): 0 is neutral, 0.2–0.5 is moderate (recommended), above 0.5 may reduce stability.
- **Speed**: 0.7–1.2 is the safe range (KIE `generate_speech` accepts exactly that); 1.1–1.2 suits social media, 0.8–0.9 explainers.

### Recommended Presets

| Video Type | Stability | Similarity | On `eleven_v4`, steer with | Style / Speed (older models) |
|---|---|---|---|---|
| Corporate narration | 0.7 | 0.6 | Plain punctuation | 0.2 / 1.0 |
| Conversational/social | 0.4 | 0.5 | `[excited]`, short sentences | 0.4 / 1.1 |
| Documentary | 0.6 | 0.7 | Ellipses for pauses | 0.3 / 0.9 |
| Energetic promo | 0.3 | 0.5 | `[excited]`, capitals for emphasis | 0.5 / 1.2 |
| Calm meditation/ASMR | 0.8 | 0.6 | `[whispers]`, ellipses | 0.1 / 0.8 |

## Multi-Voice Scripts

For videos with multiple speakers (interviews, dialogues, characters):

1. Give each `voiceover` entry in the script its own `voiceId` and pass it to `textToSpeech.convert` instead of the single `VOICE_ID`. Name one file per line: `vo-line01-narrator`, `vo-line02-interviewer`, `vo-line03-guest`, …
2. Measure every line in `calculateMetadata` and compute each line's start frame as the running sum of the previous lines (plus a small gap), exactly like the per-scene pattern in `voiceover-sync.md`.
3. Place each line with `<Audio>` from `@remotion/media`, with `from` set to its start frame directly on the `<Audio>` (official `remotion-markup` audio.md, "Delaying").

Keep a table of speaker → voice ID in the project so lines can be regenerated consistently.

## Voice Library

Find a voice, then put its ID in the script:

```ts
// Voices already in the user's account (pre-made, cloned, saved)
const mine = await client.voices.search({ search: "narrator", pageSize: 10 });

// The shared community library
const shared = await client.voices.getShared({ search: "deep british documentary", pageSize: 10 });
```

Both return voices with their IDs, names and descriptions. Put the filter in the `search` text, e.g.:
- **Category**: narration, conversational, characters, news
- **Language**: English, Spanish, French, etc.
- **Gender**: male, female
- **Age**: young, middle-aged, old

Deprecated MCP alternative: `search_voices` (`search`) for your account and `search_voice_library` (`search`, `page_size`) for the shared library.

## Voice Changer

To keep a performance and change who's speaking (a scratch read re-voiced as the brand voice, a character voice), follow the official `voice-changer` skill: `speechToSpeech.convert(voiceId, { audio, modelId: "eleven_multilingual_sts_v2" })`, up to 5 minutes per request. Read the source from `public/` and save the result as `vo-…` (e.g. `vo-scene1-brand.mp3`).

## Audio Isolation

Extract clean voice from noisy recordings with the official `voice-isolator` skill: `audioIsolation.convert({ audio: createReadStream("public/sample-noisy.mp3") })`, saved as `public/sample-clean.mp3` (or `vo-scene1-clean.mp3` for narration). It accepts video files too.

Deprecated MCP alternative: `isolate_audio` with `input_file_path` set to the absolute path of a file inside `public/` (a local file, not a URL). Rename the result to the project convention.

Useful when:
- User provides a reference voice sample with background noise
- Cleaning up recorded narration before using in Remotion
- Extracting dialogue from video clips
- Prepping audio before transcription (`captions-workflow.md`)

## Best Practices

1. **Start with the script** in `audio-integration.md` — the same SDK script covers basic and advanced voice work
2. **Use the official skills** for cloning inputs, voice changing and isolation; the MCP is a deprecated shortcut
3. **Test voice clones with short text first** before generating full narration
4. **Keep stability at 0.5-0.7** for professional narration
5. **Keep inputs and outputs in `public/`** — the MCP can't see anything else, and `staticFile()` needs it anyway
6. **Generate one line at a time** for multi-voice scripts, then sequence in Remotion
7. **Save voice IDs** — note which voice ID was used so you can regenerate consistently
8. **Respect voice cloning ethics** — only clone voices you have permission to use
9. **Use `eleven_v4`** for best quality across languages (90+); fall back to `eleven_multilingual_v2` only for very long single reads that must stay even
