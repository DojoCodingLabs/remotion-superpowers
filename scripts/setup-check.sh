#!/bin/bash
# Remotion Superpowers — Setup Check
# Validates that all dependencies and API keys are configured.

set -o pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "🎬 Remotion Superpowers — Setup Check"
echo "======================================"
echo ""

ERRORS=0
WARNINGS=0

# --- Dependencies ---
echo "📦 Dependencies"
echo ""

# Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    NODE_MAJOR=$(echo "$NODE_VERSION" | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 22 ]; then
        echo -e "  ${GREEN}✓${NC} Node.js $NODE_VERSION"
    else
        echo -e "  ${RED}✗${NC} Node.js $NODE_VERSION (need >= 22.18)"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "  ${RED}✗${NC} Node.js not found"
    ERRORS=$((ERRORS + 1))
fi

# npm
if command -v npm &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} npm $(npm --version)"
else
    echo -e "  ${RED}✗${NC} npm not found"
    ERRORS=$((ERRORS + 1))
fi

# Python
if command -v python3 &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Python $(python3 --version 2>&1 | awk '{print $2}')"
elif command -v python &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Python $(python --version 2>&1 | awk '{print $2}')"
else
    echo -e "  ${YELLOW}⚠${NC} Python not found (only for the optional ElevenLabs MCP server)"
    WARNINGS=$((WARNINGS + 1))
fi

# uv/uvx
if command -v uvx &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} uvx found"
else
    echo -e "  ${YELLOW}⚠${NC} uvx not found (only for the optional ElevenLabs MCP server)"
    echo "     Install: curl -LsSf https://astral.sh/uv/install.sh | sh"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# --- Remotion Project ---
echo "🎥 Remotion Project"
echo ""

if [ -f "remotion.config.ts" ] || [ -f "remotion.config.js" ]; then
    echo -e "  ${GREEN}✓${NC} Remotion project detected"
else
    echo -e "  ${YELLOW}⚠${NC} No Remotion project in current directory"
    echo "     Run: npx create-video@latest"
    WARNINGS=$((WARNINGS + 1))
fi

# Remotion Skills
if [ -d ".claude/skills/remotion-best-practices" ]; then
    echo -e "  ${GREEN}✓${NC} Remotion skills installed"
else
    echo -e "  ${YELLOW}⚠${NC} Remotion skills not installed"
    echo "     Run: npx skills add remotion-dev/skills"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# --- API Keys ---
echo "🔑 API Keys"
echo ""

# ElevenLabs (voice, SFX, music)
if [ -n "$ELEVENLABS_API_KEY" ]; then
    echo -e "  ${GREEN}✓${NC} ELEVENLABS_API_KEY is set"
else
    echo -e "  ${RED}✗${NC} ELEVENLABS_API_KEY not set (voiceover, sound effects, music)"
    echo "     Signup: https://elevenlabs.io"
    ERRORS=$((ERRORS + 1))
fi

# KIE (images, clips)
if [ -n "$KIE_API_KEY" ]; then
    echo -e "  ${GREEN}✓${NC} KIE_API_KEY is set"
else
    echo -e "  ${RED}✗${NC} KIE_API_KEY not set (AI images and video clips)"
    echo "     Signup: https://kie.ai"
    ERRORS=$((ERRORS + 1))
fi

# TwelveLabs
if [ -n "$TWELVELABS_API_KEY" ]; then
    echo -e "  ${GREEN}✓${NC} TWELVELABS_API_KEY is set"
else
    echo -e "  ${RED}✗${NC} TWELVELABS_API_KEY not set (video understanding)"
    echo "     Signup: https://www.twelvelabs.io"
    ERRORS=$((ERRORS + 1))
fi

# Pexels
if [ -n "$PEXELS_API_KEY" ]; then
    echo -e "  ${GREEN}✓${NC} PEXELS_API_KEY is set"
else
    echo -e "  ${YELLOW}⚠${NC} PEXELS_API_KEY not set (free stock footage)"
    echo "     Signup: https://www.pexels.com/api/ (free)"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# --- Summary ---
echo "======================================"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Ready to create videos.${NC}"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) — some features may be limited.${NC}"
else
    echo -e "${RED}✗ $ERRORS error(s), $WARNINGS warning(s) — fix errors before proceeding.${NC}"
fi
echo ""

exit $ERRORS
