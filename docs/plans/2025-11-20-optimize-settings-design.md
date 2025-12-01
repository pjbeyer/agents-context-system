# Optimize Settings Command - Design Document

**Date:** 2025-11-20
**Issue:** #2 - Develop optimize-settings command
**Branch:** feature/optimize-settings-impl

## Overview

The `/optimize-settings` command provides comprehensive optimization of Claude Code configuration settings across user and project levels. It analyzes all settings types (environment, permissions, plugins, UI), provides prioritized recommendations, and implements approved changes with full documentation.

## Requirements

### Scope
- **All settings types**: env, permissions, plugins, model, UI, MCP, statusLine
- **Settings hierarchy**: User-level (`~/.claude/settings.json`) applies everywhere; working directory overrides
- **No cascading inheritance**: Only user + current directory (Claude Code limitation)

### Interaction Model
- **HIGH priority**: Individual approval (high risk OR security-related)
- **MEDIUM priority**: Batch approval (moderate impact, low risk)
- **LOW priority**: Auto-apply with summary (low impact AND low risk)

### Documentation
- **Location**: `~/Projects/.workflow/docs/optimization/settings/`
- **Artifacts**: Optimization reports, best practices guide, settings philosophy
- **Tracking**: History of optimizations, rollback instructions

### Context Adaptation
- **Global mode**: From `~/Projects` or `~` - scans all profiles/projects
- **Project mode**: From project directory - analyzes user + current project
- **User mode**: From `~/.claude` - focuses on user-level only

## Architecture

### Core Components

#### 1. Context Detection
Determines invocation location and adapts behavior:

```bash
cwd=$(pwd)
case "$cwd" in
  "$HOME"|"$HOME/Projects"|"$HOME/Projects/")
    mode="global" ;;
  "$HOME/.claude"|"$HOME/.claude/"*)
    mode="user" ;;
  "$HOME/Projects/"*/*)
    if [[ -f "AGENTS.md" ]]; then
      mode="project"
    else
      mode="global"
    fi ;;
  *)
    mode="user" ;;
esac
```

**Modes:**
- **Global**: Scans user + all profiles (work/pjbeyer/play/home)
- **Project**: Scans user + current project only
- **User**: Scans only `~/.claude/settings.json`

#### 2. Settings Discovery
Finds relevant settings files based on mode:

- User-level: `~/.claude/settings.json` (always)
- Project-level: `.claude/settings.json` in relevant directories
- No parent directory scanning (no inheritance in Claude Code)

#### 3. Multi-Category Analysis
Five analysis types run in parallel:

**A. Consolidation & Cleanup**
- Duplicate permissions (user vs project)
- Wildcard opportunities (multiple similar patterns → single wildcard)
- Dead references (permissions for uninstalled plugins/skills)
- Unused paths (`additionalDirectories` that don't exist)

**B. Security Analysis**
- Overly permissive patterns (`Read(//**)`, `Bash(*:*)`)
- Missing security denials (credentials, secrets, SSH keys)
- Allow/deny contradictions
- Path exposure risks

**C. Migration Guidance**
- Common project patterns (same permission in 3+ projects)
- User-level candidates (move from project → user)
- Project-specific validation (some should stay local)

**D. Performance & Best Practices**
- Pattern ordering (specific before general for faster matching)
- Environment variable opportunities (repeated paths)
- Deprecated settings
- Plugin conflicts

**E. Best Practices**
- Settings alignment with documentation
- Recommended patterns for common use cases
- Plugin configuration standards

#### 4. Priority Classification
Hybrid model based on risk and impact:

**HIGH Priority** (individual approval required):
- Security-related changes
- High-risk modifications (could break workflows)
- Overly permissive patterns
- Allow/deny contradictions

**MEDIUM Priority** (batch approval):
- Moderate impact with low risk
- Consolidations that save tokens
- Migration suggestions
- Performance improvements

**LOW Priority** (auto-apply with summary):
- Low impact AND low risk
- Formatting and ordering
- Minor cleanups
- Non-breaking optimizations

#### 5. Interactive Application
Three-phase approval process:

**Phase 1: HIGH Priority (Individual)**
- Present one recommendation at a time
- Show: what, why, impact, before/after
- Ask: "Apply this change? (y/n/skip all HIGH)"
- User controls each high-risk change

**Phase 2: MEDIUM Priority (Batch)**
- Group recommendations by category
- Show summary with counts
- Display full list with explanations
- Ask: "Apply all MEDIUM changes? (y/n/show details)"
- Single approval for batch

**Phase 3: LOW Priority (Auto-Apply)**
- Automatically apply safe changes
- Show summary of what was done
- List changes in terminal
- No approval needed

**Phase 4: Implementation**
- Backup: `.claude/settings.json.backup-YYYYMMDD-HHMMSS`
- Apply changes: HIGH → MEDIUM → LOW
- Show final diff
- Update documentation

#### 6. Documentation Generation
Produces three artifacts:

**A. Optimization Report**
`~/Projects/.workflow/docs/optimization/settings/YYYY-MM-DD-optimization-report.md`

Contains:
- Executive summary (counts by priority)
- Analysis results per category
- Applied changes (before/after)
- Declined recommendations
- Rollback instructions
- Next review date

**B. Best Practices Guide**
`~/Projects/.workflow/docs/optimization/settings/README.md`

Contains (created on first run, updated on subsequent runs):
- Settings hierarchy explanation
- Permission patterns with rationale
- Migration strategy guidelines
- Plugin philosophy
- Optimization history
- Evolving best practices

**C. Settings Backup**
`~/.claude/settings.json.backup-YYYYMMDD-HHMMSS`

- Created before any changes
- Enables easy rollback
- Suggest cleanup after 30 days

## Analysis Categories Detail

### 1. Consolidation & Cleanup

**Duplicate Detection:**
- Compare user vs project permissions
- Find identical entries
- Recommend removal from project (user takes precedence)

**Wildcard Opportunities:**
```json
// BEFORE (8 entries)
"Skill(phil-ai-learning:*)",
"Skill(phil-ai-docs:*)",
"Skill(phil-ai-context:*)"

// AFTER (1 entry)
"Skill(agents-*:*)"
```

**Dead References:**
- Check `enabledPlugins` against installed plugins
- Verify skill permissions reference existing skills
- Flag permissions for non-existent paths

**Unused Paths:**
```json
// Check each additionalDirectories entry
"additionalDirectories": [
  "/Users/pjbeyer/.claude/plugins/cache/",  // ✓ exists
  "/Users/pjbeyer/old-project/"              // ✗ doesn't exist → remove
]
```

### 2. Security Analysis

**Overly Permissive Patterns:**
```json
// HIGH priority flags
"Read(//Users/**)"           // Too broad
"Bash(*:*)"                  // Allows any bash command
"Write(~/**)"                // Can write anywhere in home

// Recommend specific alternatives
"Read(//Users/pjbeyer/Projects/**)"
"Bash(git:*)",
"Bash(npm:*)"
"Write(~/Projects/**)"
```

**Missing Denials:**
```json
// Check for critical security denials
"deny": [
  "Read(.env)",                        // ✓ present
  "Read(**/.env.*)",                   // ✓ present
  "Read(~/.ssh/id_*)",                 // ✓ present
  "Read(~/.gnupg/**)",                 // ✗ missing → suggest
  "Write(~/.bash_history)",            // ✗ missing → suggest
  "Bash(curl *| bash:*)",              // ✗ missing → suggest
  "Bash(wget *| sh:*)"                 // ✗ missing → suggest
]
```

**Contradictions:**
```json
// HIGH priority: allow undermines deny
"allow": ["Read(~/.ssh/**)"],
"deny": ["Read(~/.ssh/id_*)"]
// Problem: allow is broader and processed first
```

### 3. Migration Guidance

**Pattern Detection Across Projects:**
```bash
# Scan all project settings
work_projects=$(find ~/Projects/work -name ".claude" -type d)

# Count permission frequency
# If "Bash(pytest:*)" appears in 3+ projects → candidate for user-level
```

**User-Level Candidates:**
- Appears in 3+ projects across any profile
- Not project-specific (no project paths in pattern)
- Generally useful across work

**Should Stay Project-Level:**
- Project-specific paths
- Project-specific MCP servers
- Temporary experimental permissions

### 4. Performance & Best Practices

**Pattern Ordering:**
```json
// BEFORE (inefficient - general patterns first)
"allow": [
  "Read(//**)",
  "Read(//Users/pjbeyer/Projects/work/**)"
]

// AFTER (efficient - specific first)
"allow": [
  "Read(//Users/pjbeyer/Projects/work/**)",
  "Read(//Users/pjbeyer/Projects/**)"
]
```

**Environment Variable Opportunities:**
```json
// BEFORE (repeated path)
"Bash(~/Projects/.workflow/scripts/**)",
"Bash(~/.claude/plugins/cache/phil-ai-learning/scripts/**:*)"

// AFTER (use env var)
"env": {
  "WORKFLOW_SCRIPTS": "~/Projects/.workflow/scripts",
  "AGENTS_SCRIPTS": "~/.claude/plugins/cache/phil-ai-learning/scripts"
},
"permissions": {
  "allow": [
    "Bash($WORKFLOW_SCRIPTS/**)",
    "Bash($AGENTS_SCRIPTS/**:*)"
  ]
}
```

**Deprecated Settings:**
- Check against known deprecated settings list
- Suggest modern alternatives
- Flag settings that may be removed in future Claude Code versions

## Context-Adaptive Behavior

### Global Mode
**Invocation:** From `~/Projects` or `~`

**Scope:**
- User-level settings
- All profile directories (work/pjbeyer/play/home)
- All project `.claude/settings.json` files

**Analysis Focus:**
- Cross-profile patterns
- Migration opportunities (project → user)
- Profile-specific patterns

**Output Example:**
```
Running in GLOBAL mode
Analyzed: user + 23 project settings across 4 profiles

Found:
- Permission "Bash(pytest:*)" in 8 work projects → move to user-level
- Permission "Skill(workflow)" in 12 projects → move to user-level
- 15 duplicate permissions across projects
```

### Project Mode
**Invocation:** From within a project directory with `AGENTS.md`

**Scope:**
- User-level settings
- Current project `.claude/settings.json` only

**Analysis Focus:**
- How project overrides relate to user baseline
- Duplicate permissions (already in user)
- Project-specific justification

**Output Example:**
```
Running in PROJECT mode
Analyzed: user + current project (phil-ai-context)

Found:
- 3 permissions duplicate user-level → remove from project
- 2 permissions project-specific → keep in project
- Project overrides: model, additionalDirectories
```

### User Mode
**Invocation:** From `~/.claude`

**Scope:**
- Only `~/.claude/settings.json`

**Analysis Focus:**
- Internal consistency
- Security best practices
- Consolidation opportunities within user settings

**Output Example:**
```
Running in USER mode
Analyzed: user-level settings only

Found:
- 8 skill permissions → consolidate to 2 wildcards
- 5 security denials missing
- Optimal ordering could improve performance
```

### Mode Override
User can force specific mode:
```bash
/phil-ai-context:optimize-settings --global      # Force global scan
/phil-ai-context:optimize-settings --user-only   # Force user-only
/phil-ai-context:optimize-settings --dry-run     # Show recommendations, don't apply
```

## Implementation Structure

### File Structure
```
phil-ai-context/
├── commands/
│   └── optimize-settings.md          # Command entry point
├── skills/
│   └── optimize-settings/
│       └── SKILL.md                   # Main optimization logic
└── config/
    └── settings-rules.json            # Rules, patterns, checks
```

### Command File
`commands/optimize-settings.md`:

```markdown
---
description: Analyze and optimize Claude Code settings with prioritized recommendations and interactive approval
---

# Optimize Settings

Comprehensive optimization of Claude Code configuration settings across user and project levels.

## Invocation

Use and follow the `optimize-settings` skill exactly as written.

## Usage

From any location:
```bash
/phil-ai-context:optimize-settings              # Context-adaptive
/phil-ai-context:optimize-settings --global     # Force global scan
/phil-ai-context:optimize-settings --user-only  # User-level only
/phil-ai-context:optimize-settings --dry-run    # Show recommendations only
```

## Related

- Skill: `optimize-settings` (implementation)
- Plugin: phil-ai-context
- Companion: `/optimize-agents`, `/optimize-mcp`
```

### Skill File Structure
`skills/optimize-settings/SKILL.md`:

**Sections:**
1. Context detection and mode selection
2. Settings discovery (user + project files)
3. JSON parsing and validation
4. Five analysis category implementations
5. Priority classification logic
6. Interactive approval flow
7. Settings file modification (backup → apply → validate)
8. Documentation generation
9. Error handling and rollback

### Configuration File
`config/settings-rules.json`:

```json
{
  "security": {
    "overly_permissive_patterns": [
      "Read(//Users/**)",
      "Read(//**)",
      "Bash(*:*)",
      "Write(~/**)"
    ],
    "required_denials": [
      "Read(.env)",
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Read(~/.ssh/id_*)",
      "Read(~/.gnupg/**)",
      "Write(~/.ssh/**)",
      "Write(~/.aws/**)",
      "Bash(rm -rf:*)",
      "Bash(sudo:*)",
      "Bash(curl *| bash:*)",
      "Bash(wget *| sh:*)"
    ]
  },
  "consolidation": {
    "wildcard_rules": {
      "Skill(agents-*-system:*)": "agents-*:*",
      "Skill(superpowers*:*)": "superpowers*:*",
      "SlashCommand(/agents-*:*)": "SlashCommand(/agents-*:*)"
    }
  },
  "deprecated": {
    "settings": [
      "approvedSkills"
    ],
    "replacements": {
      "approvedSkills": "permissions.allow with Skill(...) patterns"
    }
  },
  "priority_rules": {
    "high": [
      "security_risk",
      "overly_permissive",
      "allow_deny_contradiction",
      "removes_security_denial"
    ],
    "medium": [
      "consolidation_with_wildcards",
      "migration_candidate",
      "performance_improvement"
    ],
    "low": [
      "formatting",
      "ordering",
      "minor_cleanup"
    ]
  }
}
```

## Integration

### With Existing Commands
- Follows same pattern as `/optimize-agents` and `/optimize-mcp`
- Can be called from comprehensive optimization workflow
- Shares utilities:
  - `detect-profile` for profile detection
  - `detect-level` for hierarchy awareness
  - Documentation utilities

### With Workflow
- Part of regular maintenance cycle
- Recommended: Run quarterly or when installing new plugins
- Pairs with `/optimize-agents` for full optimization

## Testing Strategy

### Test Cases

**1. Context Detection:**
- Run from `~/Projects` → global mode
- Run from `~/Projects/work/some-project` → project mode
- Run from `~/.claude` → user mode
- Verify mode override flags work

**2. Analysis Categories:**
- Test with real settings (current settings are complex enough)
- Verify each category finds known issues
- Check priority classification accuracy

**3. Interactive Flow:**
- Mock user input for approval testing
- Verify HIGH items presented individually
- Verify MEDIUM items batched correctly
- Verify LOW items auto-applied

**4. Settings Modification:**
- Verify JSON remains valid after changes
- Test backup creation
- Test rollback from backup
- Check file permissions preserved

**5. Documentation:**
- Verify report generation
- Check README.md creation/update
- Validate markdown formatting

### Dry-Run Mode
- `--dry-run` flag shows all recommendations without applying
- Useful for testing classification logic
- Safe way to preview changes

## Rollback Procedure

If changes cause issues:

```bash
# Find latest backup
ls -lt ~/.claude/settings.json.backup-* | head -1

# Restore from backup
cp ~/.claude/settings.json.backup-YYYYMMDD-HHMMSS ~/.claude/settings.json

# Verify restoration
diff ~/.claude/settings.json ~/.claude/settings.json.backup-YYYYMMDD-HHMMSS
```

## Future Enhancements

**Phase 2 (Future):**
- AI-powered pattern learning (learn from user's approval/rejection patterns)
- Settings templating (save/apply setting profiles)
- Automated migration testing (test that changes don't break workflows)
- Integration with plugin installation (suggest permissions when installing plugins)
- Settings diff tool (compare settings across profiles)

## Success Criteria

The `/optimize-settings` command is successful when:

1. **Finds real issues**: Identifies actual inefficiencies, security gaps, or duplications
2. **Prioritizes correctly**: HIGH items are truly high-risk/security-related
3. **Saves time**: User approves most MEDIUM items (good recommendations)
4. **Safe**: LOW auto-applied changes never break anything
5. **Well-documented**: README.md becomes the authoritative settings guide
6. **Maintainable**: Easy to add new rules and analysis patterns
7. **Fast**: Completes analysis in < 10 seconds for typical settings
8. **Reliable**: Backups always work, rollback always possible

## Example Session

```bash
$ cd ~/Projects
$ /phil-ai-context:optimize-settings

🔍 Context Detection
Running in GLOBAL mode (scanning all profiles)

📊 Analysis Complete
Found 47 recommendations across 5 categories:
- Consolidation: 18 opportunities
- Security: 3 concerns
- Migration: 12 candidates
- Performance: 8 improvements
- Best Practices: 6 suggestions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HIGH PRIORITY (3 recommendations)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/3] Security Concern: Overly Permissive Pattern

Current:  "Read(//Users/**)"
Problem:  Allows reading ANY file in /Users (all users)
Suggest:  "Read(//Users/pjbeyer/Projects/**)"
Impact:   Restricts access to your projects only
Risk:     Could expose sensitive files in other user directories

Apply this change? (y/n/skip all HIGH): y
✓ Applied

[2/3] Security Concern: Missing Security Denial
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MEDIUM PRIORITY (32 recommendations)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Consolidation (18):
- Consolidate 8 Skill(agents-...) → Skill(agents-*:*)
- Consolidate 5 Bash(git ...) → already have Bash(git:*)
- Remove 5 duplicate permissions (already in user-level)

Migration (12):
- Move "Bash(pytest:*)" from 8 projects → user-level
- Move "Skill(workflow)" from 12 projects → user-level

Performance (2):
- Reorder permissions (specific before general)

Apply all MEDIUM priority changes? (y/n/show details): y
✓ Applied 32 changes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
LOW PRIORITY (12 auto-applied)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Formatted permissions (alphabetical order)
✓ Removed 3 unused additionalDirectories
✓ Cleaned up whitespace
✓ Optimized permission ordering

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Backup created: ~/.claude/settings.json.backup-20250120-143052
✓ Applied 47 changes total
✓ Report: ~/Projects/.workflow/docs/optimization/settings/2025-01-20-optimization-report.md
✓ Updated: ~/Projects/.workflow/docs/optimization/settings/README.md

Settings optimized successfully!
Next review suggested: April 2025
```

## Conclusion

The `/optimize-settings` command provides comprehensive, intelligent optimization of Claude Code settings with appropriate safety controls and excellent documentation. It balances automation (LOW priority) with user control (HIGH priority), making it both efficient and safe to use regularly.
