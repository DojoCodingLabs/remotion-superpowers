#!/bin/bash
# Remotion Superpowers — Post-tool note hook
# Called by Claude Code after MCP tool execution to provide tips.
#
# Usage: sh scripts/post-tool-note.sh <note-type>
# Receives hook JSON on stdin. Outputs JSON on stdout.
#
# Exit code 0 = success (always continues, just adds context).

NOTE_TYPE="${1:-unknown}"

# Read stdin (hook JSON) — consume it
cat > /dev/null 2>&1

case "$NOTE_TYPE" in
  pexels-attribution)
    echo "{\"reason\": \"Reminder: Pexels content is free but attribution is appreciated. Consider adding 'Media by Pexels' in your video credits.\"}"
    ;;
  captions-tip)
    echo "{\"reason\": \"Tip: If this video is for social media, consider adding TikTok-style captions with /add-captions. 85% of social videos are watched without sound.\"}"
    ;;
  *)
    # Unknown note type — no output, just pass through
    ;;
esac

exit 0
