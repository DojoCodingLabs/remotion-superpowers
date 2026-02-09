---
name: review-video
description: Review a rendered video with AI vision. Uses TwelveLabs to watch the output, analyze pacing/composition/audio sync, and provide actionable feedback for improvement. The feedback loop that closes the production circle.
---

# Review Video — AI-Powered Video Feedback Loop

You are reviewing a rendered Remotion video using TwelveLabs to "watch" it and provide professional feedback. This closes the production loop — render, review, improve, repeat.

**Load the `remotion-production` skill** for the `video-analysis` rule.

## Workflow

### 1. Find the Rendered Video

Look for the output video:

```bash
ls out/ 2>/dev/null | grep -E '\.(mp4|webm|mov)$'
```

If no rendered video exists, tell the user to render first:
```bash
npx remotion render [CompositionId] out/video.mp4
```

### 2. Index with TwelveLabs

```
Use TwelveLabs MCP to:
1. Create an index (or use existing)
2. Upload the rendered video
3. Wait for indexing to complete
```

### 3. Analyze — The Director's Review

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

### 4. Present the Review

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
  Then re-render and run /review-video again.
```

### 5. Implement Fixes

Ask the user if they want to apply the suggested fixes. If yes:
1. Make the code changes
2. Preview with `npm run dev`
3. Re-render: `npx remotion render [CompositionId] out/video.mp4`
4. Offer to run `/review-video` again to verify improvements

### 6. Iteration Loop

Keep iterating until the user is satisfied or the review shows no major issues.

The loop: **Render → Review → Fix → Render → Review** until quality is right.

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
