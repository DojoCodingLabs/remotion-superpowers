# Captions Workflow: Style Presets on Top of the Official Captions Flow

## Overview

Captions matter on social media, where 85% of videos are watched without sound. The official `remotion-captions` skill owns transcription, the `Caption` type and display. This rule adds only two things on top: **style presets** (TikTok, YouTube, karaoke, minimal) and **platform safe-zone placement**.

Follow official `remotion-captions` for every API detail:
- `transcribe-captions.md`: word-level transcription with `@remotion/whisper-webgpu`
- `display-captions.md`: copy a caption element into the project, one per clip, captions inlined
- `import-srt-captions.md`: turn an `.srt` file into `Caption` objects with `parseSrt()`

Install `@remotion/captions` with `npx remotion add @remotion/captions`, as official shows.

## Pick the transcription route

Both routes give **word-level** `Caption[]` (one entry per word), so every preset works with either.

| Route | Use it when | How |
|---|---|---|
| **1. Official whisper-webgpu** (default) | A compatible GPU is available | The Node script in official `remotion-captions/transcribe-captions.md` (`@remotion/whisper-webgpu`, `toCaptions({ whisperWebGpuOutput })`). Local and free. ONNX Runtime doesn't run on Linux arm64. `small.en` for English; for other languages use a multilingual model and pass `language` (there's no auto-detect). |
| **2. ElevenLabs Scribe** (fallback) | `canUseWhisperWebGpu()` says no: no GPU, CI runners, Linux arm64, many VMs | Scribe v2 per the official ElevenLabs `speech-to-text` skill, converted with `elevenLabsTranscriptToCaptions()` from `@remotion/elevenlabs` (below). Cloud and paid (`ELEVENLABS_API_KEY`); it sends the audio to ElevenLabs, so tell the user. |
| **User-supplied `.srt`** | The user already has subtitles | Put the file in `public/` and read it with `parseSrt()`, per official `import-srt-captions.md`. SRT is **line-level**: each caption is a whole line, so only the YouTube and minimal presets fit. |

### Scribe fallback

Install with `npx remotion add @remotion/elevenlabs`. This is the request from Remotion's `elevenLabsTranscriptToCaptions()` docs (https://www.remotion.dev/docs/elevenlabs); the raw REST call keeps the JSON in the shape the function expects. Run it as a Node script from the project root (`node scripts/transcribe-scribe.ts`), never in the browser, where it would expose the key:

```ts
// scripts/transcribe-scribe.ts
import { elevenLabsTranscriptToCaptions } from "@remotion/elevenlabs";
import { readFileSync, writeFileSync } from "node:fs";

const source = "vo-scene1.mp3"; // inside public/; video files work too

const form = new FormData();
form.append("file", new Blob([readFileSync(`public/${source}`)]));
form.append("model_id", "scribe_v2");
form.append("timestamps_granularity", "word");

const response = await fetch("https://api.elevenlabs.io/v1/speech-to-text", {
  method: "POST",
  headers: { "xi-api-key": process.env.ELEVENLABS_API_KEY! },
  body: form,
});
if (!response.ok) throw new Error(`Scribe failed: ${response.status} ${await response.text()}`);

const { captions } = elevenLabsTranscriptToCaptions({ transcript: await response.json() });
writeFileSync(`public/${source.replace(/\.\w+$/, "")}.captions.json`, JSON.stringify(captions, null, 2));
```

The official `speech-to-text` skill lists the optional fields you can append to the form: `language_code` (Scribe auto-detects otherwise), `keyterms` for product names it might mishear, and `diarize` for several speakers. Scribe accepts audio and video (MP4, MOV, …) up to 5 GB.

Don't use the ElevenLabs MCP `speech_to_text` tool for captions: it returns plain text with no timestamps.

Whichever route you use:
- **Transcribe each source file on its own** (one voiceover per scene, one clip at a time), and save it as `public/<source>.captions.json`. Keep timestamps relative to the start of that file. Don't add composition offsets or merge transcripts into one timeline (official transcribe-captions.md).
- Every `Caption` needs `text`, `startMs`, `endMs`, `timestampMs` and `confidence` (the last two may be `null`). Each word's `text` starts with a space (`" world"`), because captions are whitespace sensitive.

## Display: one element per clip

Follow official `display-captions.md` exactly:
1. Fetch the element source (`https://www.remotion.dev/elements/captions/<element>.md`) and copy its `.tsx` file into the project.
2. Put the element **inside the same `<Sequence>` / `<TransitionSeries.Sequence>` as the clip or voiceover it captions**, with trimming and `playbackRate` on that shared parent.
3. **Inline the caption array** in the `captions` prop (paste the JSON, or the `parseSrt()` output). That lets the Studio Caption editor write back. `captions={captions}` from a variable or prop leaves nothing for the editor to update.

Don't build a custom caption component or one global caption overlay on top of the whole composition.

## Style presets

Each preset is a choice of official element plus styling on it. Change only:
- the element's props: `width`, `style` (position) and `combineTokensWithinMilliseconds` (how long a page holds)
- the named style constants at the top of the copied file (colors, font, size)

Leave its timing and paging logic alone.

| Preset | Official element | Needs word-level? | Styling on top |
|---|---|---|---|
| **TikTok** (default for shorts) | Popping Word Captions (`popping-word-captions`) | Yes | Highlight `#FFD700` (or brand color), white text with a black outline, bold 700-800, about 64-80px at 1080 wide. 2-4 words per page (`combineTokensWithinMilliseconds` around 800). Center or lower third. |
| **Karaoke** | Word Highlight Captions (`word-highlight-captions`) | Yes | The full sentence stays on screen and the active word changes color. Use a larger `combineTokensWithinMilliseconds` (1500-3000) so a whole phrase fits on a page. Change the highlight to `#FFD700` with dark text if you want a "box" look. |
| **YouTube** | Basic Captions (`basic-captions`) | No: also works with an imported SRT | Keep its translucent dark box. About 32-44px at 1920 wide, sentence at a time, bottom 5-10%. |
| **Minimal** | Basic Captions | No: also works with an imported SRT | Smaller size (about 36px at 1080 wide), bottom-left, lower box opacity. |

If the user asked for word highlighting but only has an SRT file, say so and transcribe the audio instead (route 1 or 2), or use the YouTube preset with their SRT.

The `style` and `width` props on the element place it. Official's example centers a 900px area in a 1920px frame with `translate: "510px 0px"` and `bottom: 120`. Compute the same way for other sizes: `(compositionWidth - width) / 2`. Animate with inline `interpolate()` and the `scale`/`translate` properties, never CSS `transition`/`animation`, as official `remotion-markup` says.

## Placement for platforms (safe zones)

Start from official `remotion-create/video-layout.md` (key text at least 80px from the sides and 100px from top and bottom at 1080 wide), then keep clear of each platform's UI:

| Platform | Caption zone | Keep clear |
|---|---|---|
| TikTok / Reels / Shorts (1080x1920) | About 15-25% up from the bottom (`bottom` around 300-480), or dead center for punchy hooks | Bottom ~15% (description, audio bar) and right ~15% (like/comment/share column). Use `width` of about 820-900. |
| YouTube landscape (1920x1080) | Bottom 5-10% (`bottom` around 60-110) | The progress bar at the very bottom |
| LinkedIn / X feed | Bottom 10-15% | The platform's mute and expand buttons in the lower corners |
| No platform constraints | Center of screen for maximum impact | |

## Key rules

1. **Word-level animation comes from a transcription (whisper-webgpu or Scribe), never from SRT.**
2. **One caption element per clip**, inside that clip's sequence, with captions inlined.
3. **Minimum sizes:** at least 48px on mobile; 64px or more for the TikTok preset at 1080 wide.
4. **High contrast:** white text with a dark outline or box, or a colored highlight on dark.
5. **Check in Studio** with the preview already open: scrub the busiest scenes and look at phone-size legibility before anyone asks for a render.
