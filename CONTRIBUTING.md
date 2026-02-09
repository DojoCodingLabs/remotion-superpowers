# Contributing to Remotion Superpowers

Thank you for helping make video production with Claude better! Here's how to contribute.

## Quick Contributions (No Code Required)

### Improve Production Rules
The `skills/remotion-production/rules/` directory contains 12 production guides. If you have better workflows, patterns, or examples for any of these areas, open a PR:

- Animation presets, transitions, visual effects
- Audio integration, music scoring, voiceover sync
- Captions workflow, stock footage workflow
- 3D content, data visualization
- CI/CD rendering, production pipeline

### Add Command Improvements
The `commands/` directory contains 13 slash commands. If you find a better prompt flow or want to add edge case handling, contributions are welcome.

## Code Contributions

### Setup

```bash
git clone https://github.com/DojoCodingLabs/remotion-superpowers.git
cd remotion-superpowers
```

### Testing Locally

```bash
# Open Claude Code
claude

# Add as local marketplace
/plugin marketplace add .

# Install
/plugin install remotion-superpowers

# Test your changes
/setup
/create-video
```

### What We Need Help With

- **New production rules** -- better workflows for specific video styles
- **MCP server integrations** -- additional media generation tools
- **Agent improvements** -- smarter orchestration, better review loops
- **Command refinements** -- better prompts, more options
- **Documentation** -- tutorials, video walkthroughs, examples

### PR Guidelines

1. Keep it focused -- one feature or fix per PR
2. Test with Claude Code locally before submitting
3. Follow the existing tone and structure
4. Update the README if adding new commands or capabilities

## Code of Conduct

Be kind and constructive. We're building tools that help creators make better videos. Everyone is welcome.

## Questions?

Open an issue or join us on [Discord](https://dojocoding.io/discord).

---

*Remotion Superpowers by [Dojo Coding Labs](https://dojocoding.io) -- from prompt to production. Free. Open source.*
