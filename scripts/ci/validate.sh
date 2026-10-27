#!/usr/bin/env bash
# Remotion Superpowers — CI validation
# Runs the same checks as .github/workflows/validate.yml. Run it locally
# from anywhere in the repo before opening a PR:
#
#   bash scripts/ci/validate.sh
#
# Needs: jq, python3, shellcheck. `claude` is optional locally (the check is
# skipped with a warning if it's missing) and required in CI.
#
# Exit code: 0 if every check passes, 1 otherwise.

set -u

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT" || exit 1

FAILURES=0

section() { printf '\n== %s\n' "$1"; }
pass() { printf '  ok   %s\n' "$1"; }
fail() { printf '  FAIL %s\n' "$1"; FAILURES=$((FAILURES + 1)); }
warn() { printf '  warn %s\n' "$1"; }

# Markdown dirs that describe tools. commands/ may go away, so only scan what exists.
DOC_DIRS=()
for d in commands agents skills; do
  [ -d "$d" ] && DOC_DIRS+=("$d")
done

# --- 1. JSON files parse ---------------------------------------------------
section "JSON files parse"
JSON_COUNT=0
while IFS= read -r -d '' f; do
  JSON_COUNT=$((JSON_COUNT + 1))
  if err=$(jq empty "$f" 2>&1); then
    pass "$f"
  else
    fail "$f: $err"
  fi
done < <(find . \( -name node_modules -o -name .git \) -prune -o -type f -name '*.json' -print0)
[ "$JSON_COUNT" -gt 0 ] || fail "no JSON files found"

# --- 2. claude plugin validate ---------------------------------------------
section "claude plugin validate"
if command -v claude >/dev/null 2>&1; then
  if out=$(claude plugin validate . 2>&1); then
    pass "claude plugin validate ."
  else
    printf '%s\n' "$out"
    fail "claude plugin validate ."
  fi
elif [ -n "${CI:-}" ]; then
  fail "claude CLI not found (install with: npm install -g @anthropic-ai/claude-code)"
else
  warn "claude CLI not found, skipping (CI runs this check)"
fi

# --- 3. shellcheck ---------------------------------------------------------
section "shellcheck scripts/*.sh"
if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck scripts/*.sh scripts/ci/*.sh; then
    pass "shellcheck"
  else
    fail "shellcheck"
  fi
else
  fail "shellcheck not found"
fi

# --- 4. Stale tool names ---------------------------------------------------
# Names that remotion-media-mcp 1.2.x and pexels-mcp-server don't expose.
# \b treats '_' as a word character, so generate_video_from_text doesn't match.
section "No stale MCP tool names in ${DOC_DIRS[*]:-(no doc dirs)}"
STALE_RE='generate_(tts|sfx)\b|\bgenerate_video\b|project_path|searchPhotos|searchVideos|downloadVideo'
if [ "${#DOC_DIRS[@]}" -gt 0 ]; then
  if hits=$(grep -rnE --include='*.md' "$STALE_RE" "${DOC_DIRS[@]}"); then
    printf '%s\n' "$hits"
    fail "stale tool names found (see CHANGELOG 2.1.1 for the current names)"
  else
    pass "no stale tool names"
  fi
fi

# --- 5. SKILL.md frontmatter -----------------------------------------------
# Agent Skills standard: frontmatter with non-empty name and description,
# and name must equal the skill's directory name.
section "skills/*/SKILL.md frontmatter"
check_frontmatter() {
  python3 - "$1" "$2" <<'PY'
import re, sys

path, dirname = sys.argv[1], sys.argv[2]
lines = open(path, encoding="utf-8").read().splitlines()
if not lines or lines[0].strip() != "---":
    sys.exit("missing YAML frontmatter (first line must be ---)")
try:
    end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
except StopIteration:
    sys.exit("frontmatter is not closed with ---")
fm = lines[1:end]

def value(key):
    for i, line in enumerate(fm):
        m = re.match(r"^%s:\s*(.*)$" % key, line)
        if not m:
            continue
        v = m.group(1).strip()
        if v in ("|", ">", "|-", ">-", "|+", ">+"):
            # Block scalar: take the following indented lines.
            body = []
            for nxt in fm[i + 1:]:
                if nxt and not nxt[0].isspace():
                    break
                body.append(nxt.strip())
            v = " ".join(b for b in body if b)
        if len(v) >= 2 and v[0] == v[-1] and v[0] in "'\"":
            v = v[1:-1]
        return v.strip()
    return None

errors = []
name = value("name")
desc = value("description")
if not name:
    errors.append("missing or empty 'name'")
elif name != dirname:
    errors.append("name '%s' does not match directory '%s'" % (name, dirname))
if not desc:
    errors.append("missing or empty 'description'")
if errors:
    sys.exit("; ".join(errors))
PY
}

SKILL_COUNT=0
for skill in skills/*/SKILL.md; do
  [ -e "$skill" ] || continue
  SKILL_COUNT=$((SKILL_COUNT + 1))
  dir=$(basename "$(dirname "$skill")")
  if err=$(check_frontmatter "$skill" "$dir" 2>&1); then
    pass "$skill"
  else
    fail "$skill: $err"
  fi
done
[ "$SKILL_COUNT" -gt 0 ] || fail "no skills/*/SKILL.md found"

# --- 6. Hook scripts -------------------------------------------------------
section "Hook scripts"

# check-mcp-server.sh blocks (exit 2, message on stderr) when the key is missing
stderr=$(echo '{}' | env -u KIE_API_KEY sh scripts/check-mcp-server.sh remotion-media KIE_API_KEY 2>&1 >/dev/null)
code=$?
if [ "$code" -eq 2 ] && [ -n "$stderr" ]; then
  pass "check-mcp-server.sh blocks with exit 2 and a stderr message when KIE_API_KEY is unset"
else
  fail "check-mcp-server.sh without KIE_API_KEY: expected exit 2 + stderr, got exit $code, stderr '${stderr}'"
fi

# ...and approves (exit 0) when the key is set
echo '{}' | KIE_API_KEY=x sh scripts/check-mcp-server.sh remotion-media KIE_API_KEY >/dev/null 2>&1
code=$?
if [ "$code" -eq 0 ]; then
  pass "check-mcp-server.sh approves with exit 0 when KIE_API_KEY is set"
else
  fail "check-mcp-server.sh with KIE_API_KEY=x: expected exit 0, got $code"
fi

# post-tool-note.sh emits valid hookSpecificOutput JSON after a remotion render
out=$(echo '{"tool_input":{"command":"npx remotion render A out.mp4"}}' | sh scripts/post-tool-note.sh captions-tip)
if printf '%s' "$out" | jq -e '.hookSpecificOutput.additionalContext | type == "string" and length > 0' >/dev/null 2>&1; then
  pass "post-tool-note.sh captions-tip emits hookSpecificOutput.additionalContext"
else
  fail "post-tool-note.sh captions-tip: expected JSON with hookSpecificOutput.additionalContext, got '${out}'"
fi

# --- 7. Cross-agent manifests stay in sync ---------------------------------
# Claude Code, Codex and Gemini CLI each have a manifest; versions must match,
# and gemini-extension.json must run the same MCP servers as .mcp.json.
section "Cross-agent manifests in sync"
if err=$(python3 - <<'PY' 2>&1
import json, sys
claude = json.load(open(".claude-plugin/plugin.json"))
market = json.load(open(".claude-plugin/marketplace.json"))
codex = json.load(open(".codex-plugin/plugin.json"))
gemini = json.load(open("gemini-extension.json"))
mcp = json.load(open(".mcp.json"))["mcpServers"]
errors = []
versions = {
    ".claude-plugin/plugin.json": claude["version"],
    ".claude-plugin/marketplace.json": market["version"],
    ".claude-plugin/marketplace.json plugins[0]": market["plugins"][0]["version"],
    ".codex-plugin/plugin.json": codex["version"],
    "gemini-extension.json": gemini["version"],
}
if len(set(versions.values())) != 1:
    errors.append("versions differ: " + ", ".join("%s=%s" % kv for kv in versions.items()))
gem = gemini.get("mcpServers", {})
if set(gem) != set(mcp):
    errors.append("gemini-extension.json servers %s != .mcp.json servers %s" % (sorted(gem), sorted(mcp)))
for name in set(gem) & set(mcp):
    if (gem[name]["command"], gem[name]["args"]) != (mcp[name]["command"], mcp[name]["args"]):
        errors.append("%s: command/args differ between gemini-extension.json and .mcp.json" % name)
gem_keys = {s["envVar"] for s in gemini.get("settings", [])}
mcp_keys = {k for s in mcp.values() for k in s.get("env_vars", [])}
if gem_keys != mcp_keys:
    errors.append("gemini settings envVars %s != .mcp.json env_vars %s" % (sorted(gem_keys), sorted(mcp_keys)))
if errors:
    sys.exit("; ".join(errors))
PY
); then
  pass "versions match and Gemini mirrors .mcp.json"
else
  fail "$err"
fi

# --- Summary ---------------------------------------------------------------
echo ""
if [ "$FAILURES" -eq 0 ]; then
  echo "All checks passed."
  exit 0
fi
echo "$FAILURES check(s) failed."
exit 1
