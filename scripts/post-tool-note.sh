#!/bin/sh
# Remotion Superpowers — Post-tool note hook
# Called by Claude Code after tool execution to provide tips.
#
# Usage: sh scripts/post-tool-note.sh <note-type>
# Receives hook JSON on stdin. Outputs hookSpecificOutput JSON on stdout,
# whose additionalContext is shown to Claude next to the tool result.
#
# Exit code 0 = success (always continues, just adds context).

NOTE_TYPE="${1:-unknown}"

INPUT=$(cat 2>/dev/null)

note() {
  echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PostToolUse\", \"additionalContext\": \"$1\"}}"
}

case "$NOTE_TYPE" in
  pexels-attribution)
    note "Reminder: Pexels content is free but attribution is appreciated. Consider adding 'Media by Pexels' in your video credits."
    ;;
  captions-tip)
    # Runs on every Bash call; only speak up after a Remotion render
    case "$INPUT" in
      *"remotion render"*)
        note "Tip: If this video is for social media, consider adding TikTok-style captions with /add-captions. 85% of social videos are watched without sound."
        ;;
    esac
    ;;
  *)
    # Unknown note type — no output, just pass through
    ;;
esac

exit 0
