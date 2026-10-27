---
name: review-video
description: Review a Remotion video with AI vision. Starts with a cheap local check of rendered still frames, then uses TwelveLabs to watch the full render, analyze pacing/composition/audio sync, and provide actionable feedback for improvement. The feedback loop that closes the production circle.
---

# Review Video — AI-Powered Video Feedback Loop

You are reviewing a Remotion video and providing professional feedback: first from a few rendered frames, then by having TwelveLabs "watch" the full render. This closes the production loop — preview, review, improve, repeat.

**Load the `remotion-production` skill** for the `video-analysis` rule. Rendering follows the official `remotion-render` skill.

**Rendering is allowed here.** Invoking `/review-video` is an explicit request to render for review, so you don't need to ask again.

## Workflow

### 1. Quick Frame Check (cheap, local)

Before uploading anything, render a handful of still frames and look at them yourself, as official `remotion-render` shows:

```bash
npx remotion render [CompositionId] out/review-frames --frames=0,45,90,150,240 --image-format=png
```

Pick frames that cover the hook, each scene's midpoint, the busiest moments (captions, overlays) and the last frame. Read the PNGs and check:
- Blank or empty frames, missing assets (a missing `staticFile()` shows as nothing or an error)
- Text readability, overflow and safe areas (official `remotion-create/video-layout.md`)
- Caption placement against the platform UI (the `captions-workflow` rule)

If these frames show obvious bugs, fix them first (see step 6) and repeat this step. That's much cheaper than a full render plus a TwelveLabs upload.

### 2. Render the Full Video

Look for an existing render:

```bash
ls -t out/ 2>/dev/null | grep -E '\.(mp4|webm|mov)$'
```

If there's none, or the code changed since it was made, render it now:
```bash
npx remotion render [CompositionId] out/video.mp4
```

### 3. Index with TwelveLabs

```
Use TwelveLabs MCP to:
1. Create an index (or use existing)
2. Upload the rendered video
3. Wait for indexing to complete
```

### 4. Analyze — The Director's Review

Run a comprehensive review across these dimensions:

**Visual Quality:**
```
Search: "Analyze the overall visual composition and quality"
- Are scenes well-framed?
- Is text readable?
- Are transitions smooth?
- Any visual glitches, flickering, or empty frames?
```

**Pacing & Timing:**
```
Search: "Analyze the pacing and scene transitions"
- Are scenes too long or too short?
- Does the video feel rushed or dragging?
- Do transitions happen at natural break points?
```

**Audio-Visual Sync:**
```
Search: "Check if spoken words match what's shown on screen"
- Does the voiceover match the visuals?
- Are sound effects timed correctly?
- Is the music mood appropriate for the visuals?
```

**Content Effectiveness:**
```
Search: "Evaluate the opening hook and call to action"
- Does the first 3 seconds grab attention?
- Is the message clear?
- Is there a clear CTA at the end?
```

### 5. Present the Review

Format the feedback as a professional director's review:

```
🎬 Video Review: [filename]
Duration: [X]s | Resolution: [WxH]

📊 Overall Score: [1-10]

✅ What's Working:
  - [positive observation 1]
  - [positive observation 2]

⚠️ Improvements Needed:
  1. [issue] → [specific fix suggestion]
  2. [issue] → [specific fix suggestion]
  3. [issue] → [specific fix suggestion]

🎯 Priority Fix:
  [the single most impactful change to make]

🔄 Next Steps:
  - [ ] [actionable task 1]
  - [ ] [actionable task 2]
  - [ ] [actionable task 3]
  Then run /review-video again.
```

### 6. Implement Fixes

Ask the user if they want to apply the suggested fixes. If yes:
1. **Preserve user changes.** Re-read the files before editing. If the user changed the code or edited things in Studio since the last turn, keep their edits and apply the fixes on top; ask if a fix would undo one of them.
2. Make the code changes
3. Check them in Studio (`npx remotion studio`, or `--no-open` with an in-app browser; open the URL it prints). Studio stays open while you iterate.
4. Offer to run `/review-video` again, which re-renders and verifies the improvements

### 7. Iteration Loop

Keep iterating until the user is satisfied or the review shows no major issues.

The loop: **Frame check → Render → Review → Fix (in Studio) → repeat** until quality is right.

## Review Checklist

For each review, check these items:

**Visuals:**
- [ ] No blank/empty frames
- [ ] Text is readable at target resolution
- [ ] Colors are consistent throughout
- [ ] Animations are smooth (no stuttering)
- [ ] Images/footage are high quality (not pixelated)

**Audio:**
- [ ] Voiceover is clear and audible
- [ ] Music volume doesn't overpower voice
- [ ] Sound effects are timed correctly
- [ ] No audio clipping or distortion
- [ ] Fade in/out at start and end

**Structure:**
- [ ] Strong opening hook (first 2-3 seconds)
- [ ] Clear narrative flow
- [ ] Appropriate pacing for platform/audience
- [ ] Clean ending with CTA (if applicable)
- [ ] Total duration matches target

**Technical:**
- [ ] Correct aspect ratio (16:9 or 9:16)
- [ ] Correct FPS (30 or 60)
- [ ] File size reasonable for target platform
- [ ] No rendering artifacts
