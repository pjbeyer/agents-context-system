---
description: Analyze and optimize Claude Code settings with prioritized recommendations and interactive approval
---

# Optimize Settings

Comprehensive optimization of Claude Code configuration settings across user and project levels.

## Invocation

Use and follow the `optimize-settings` skill exactly as written.

## Usage

**Important**: This is a Claude Code slash command, not a shell executable. Use it through Claude Code's command system or the SlashCommand tool.

From any location in your project hierarchy:

```bash
/phil-ai-context:optimize-settings              # Context-adaptive mode
/phil-ai-context:optimize-settings --global     # Force global scan
/phil-ai-context:optimize-settings --user-only  # User-level only
/phil-ai-context:optimize-settings --dry-run    # Show recommendations without applying
```

The skill will:
1. Detect context and adapt scope
2. Discover all relevant settings files
3. Run five analysis categories
4. Classify recommendations by priority
5. Walk through approvals (HIGH individual, MEDIUM batch, LOW auto)
6. Apply approved changes with backup
7. Generate comprehensive documentation

## Optimization Areas

### Consolidation
- Duplicate permissions across levels
- Wildcard consolidation opportunities
- Dead references (uninstalled plugins/skills)
- Unused additionalDirectories

### Security
- Overly permissive patterns
- Missing security denials
- Allow/deny contradictions
- Path exposure risks

### Migration
- Common patterns across projects → user-level
- Project-specific validation
- Cross-profile pattern detection

### Performance
- Permission ordering (specific before general)
- Environment variable opportunities
- Deprecated settings

### Best Practices
- Settings alignment with documentation
- Plugin configuration standards
- Recommended patterns

## Context Modes

**Global Mode** (from ~/Projects or ~):
- Scans all profiles and projects
- Identifies cross-profile patterns
- Suggests user-level migrations

**Project Mode** (from project directory):
- Analyzes user + current project
- Focuses on duplicates and overrides
- Faster, targeted analysis

**User Mode** (from ~/.claude):
- User-level settings only
- Internal consistency checks
- Security and best practices

## Documentation

Produces comprehensive artifacts in `~/Projects/.workflow/docs/optimization/settings/`:
- Optimization reports with before/after
- Best practices guide (evolves over time)
- Settings backups for rollback

## Related

- Skill: `optimize-settings` (implementation)
- Plugin: phil-ai-context
- Companion: `/optimize-agents`, `/optimize-mcp`
- Design: `docs/plans/2025-11-20-optimize-settings-design.md`
