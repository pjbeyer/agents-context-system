# Optimize Settings Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement `/optimize-settings` command that comprehensively analyzes and optimizes Claude Code settings with context-adaptive behavior and interactive approval flow.

**Architecture:** Skill-based command following agents-context-system patterns. Context detection determines scope (global/project/user), five analysis categories classify recommendations by priority, interactive approval flow applies changes with full documentation and backup.

**Tech Stack:** Bash scripting, JSON parsing (jq), markdown generation, git integration

---

## Task 1: Create Settings Rules Configuration

**Files:**
- Create: `config/settings-rules.json`

**Step 1: Create config directory if needed**

```bash
mkdir -p config
```

**Step 2: Create settings rules file**

Create `config/settings-rules.json`:

```json
{
  "security": {
    "overly_permissive_patterns": [
      "Read(//Users/**)",
      "Read(//**)",
      "Bash(*:*)",
      "Write(~/**)",
      "Write(//**)"
    ],
    "required_denials": [
      "Read(.env)",
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Read(~/.ssh/id_*)",
      "Read(~/.ssh/id_*.pub)",
      "Read(~/.gnupg/**)",
      "Write(~/.ssh/**)",
      "Write(~/.aws/**)",
      "Write(~/.gnupg/**)",
      "Bash(rm -rf:*)",
      "Bash(sudo:*)",
      "Bash(curl *| bash:*)",
      "Bash(wget *| sh:*)",
      "Bash(eval:*)"
    ],
    "contradiction_checks": true
  },
  "consolidation": {
    "wildcard_patterns": {
      "Skill(agents-*-system:*)": "Skill(agents-*:*)",
      "Skill(agents-*-suite:*)": "Skill(agents-*:*)",
      "Skill(superpowers:*)": "Skill(superpowers:*)",
      "SlashCommand(/agents-*:*)": "SlashCommand(/agents-*:*)",
      "SlashCommand(/work-*:*)": "SlashCommand(/work-*:*)"
    },
    "minimum_instances_for_consolidation": 3
  },
  "migration": {
    "minimum_projects_for_user_level": 3,
    "exclude_patterns": [
      "**/project-specific-path/**",
      "**/.git/**"
    ]
  },
  "performance": {
    "specific_before_general": true,
    "env_var_threshold": 2
  },
  "deprecated": {
    "settings": [
      "approvedSkills"
    ],
    "replacements": {
      "approvedSkills": "Use permissions.allow with Skill(...) patterns instead"
    }
  },
  "priority_rules": {
    "high": [
      "security_risk",
      "overly_permissive",
      "allow_deny_contradiction",
      "removes_security_denial",
      "deprecated_setting"
    ],
    "medium": [
      "consolidation_with_wildcards",
      "migration_candidate",
      "performance_improvement",
      "duplicate_permission"
    ],
    "low": [
      "formatting",
      "ordering",
      "minor_cleanup",
      "whitespace"
    ]
  }
}
```

**Step 3: Verify JSON validity**

Run:
```bash
jq empty config/settings-rules.json
```

Expected: No output (success)

**Step 4: Commit**

```bash
git add config/settings-rules.json
git commit -m "feat(optimize-settings): add settings optimization rules config"
```

---

## Task 2: Create Command File

**Files:**
- Create: `commands/optimize-settings.md`

**Step 1: Create command file**

Create `commands/optimize-settings.md`:

```markdown
---
description: Analyze and optimize Claude Code settings with prioritized recommendations and interactive approval
---

# Optimize Settings

Comprehensive optimization of Claude Code configuration settings across user and project levels.

## Invocation

Use and follow the `optimize-settings` skill exactly as written.

## Usage

From any location in your project hierarchy:

\`\`\`bash
/optimize-settings              # Context-adaptive mode
/optimize-settings --global     # Force global scan
/optimize-settings --user-only  # User-level only
/optimize-settings --dry-run    # Show recommendations without applying
\`\`\`

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
- Plugin: agents-context-system
- Companion: `/optimize-agents`, `/optimize-mcp`
- Design: `docs/plans/2025-11-20-optimize-settings-design.md`
```

**Step 2: Verify markdown formatting**

Run:
```bash
head -20 commands/optimize-settings.md
```

Expected: Shows frontmatter and header correctly

**Step 3: Commit**

```bash
git add commands/optimize-settings.md
git commit -m "feat(optimize-settings): add command entry point"
```

---

## Task 3: Create Skill File - Structure and Context Detection

**Files:**
- Create: `skills/optimize-settings/SKILL.md`

**Step 1: Create skill directory**

```bash
mkdir -p skills/optimize-settings
```

**Step 2: Create skill file with frontmatter and context detection**

Create `skills/optimize-settings/SKILL.md`:

```markdown
---
name: optimize-settings
description: Analyze and optimize Claude Code settings across user and project levels with prioritized recommendations and interactive approval. Masters settings optimization.
---

# Settings Optimization Skill

Comprehensive optimization of Claude Code configuration settings with context-adaptive behavior.

## Overview

This skill analyzes Claude Code settings files, classifies recommendations by priority (HIGH/MEDIUM/LOW), and implements approved changes with full documentation and backup support.

## Context Detection

**Step 1: Determine invocation mode**

\`\`\`bash
cwd=$(pwd)
home_normalized="$HOME"

# Detect mode based on current directory
if [[ "$cwd" == "$home_normalized" ]] || \\
   [[ "$cwd" == "$home_normalized/Projects" ]] || \\
   [[ "$cwd" == "$home_normalized/Projects/" ]]; then
    mode="global"
    echo "🌍 Running in GLOBAL mode (scanning all profiles)"
elif [[ "$cwd" == "$home_normalized/.claude"* ]]; then
    mode="user"
    echo "👤 Running in USER mode (user-level settings only)"
elif [[ "$cwd" == "$home_normalized/Projects/"*/*  ]]; then
    # Check if in project (has AGENTS.md) or profile directory
    if [[ -f "AGENTS.md" ]]; then
        mode="project"
        echo "📁 Running in PROJECT mode (user + current project)"
    else
        mode="global"
        echo "🌍 Running in GLOBAL mode (scanning all profiles)"
    fi
else
    mode="user"
    echo "👤 Running in USER mode (user-level settings only)"
fi
\`\`\`

**Step 2: Check for mode override flags**

\`\`\`bash
# Check if $ARGUMENTS contains flags
if [[ "$ARGUMENTS" == *"--global"* ]]; then
    mode="global"
    echo "🔧 Override: Forced GLOBAL mode"
elif [[ "$ARGUMENTS" == *"--user-only"* ]]; then
    mode="user"
    echo "🔧 Override: Forced USER mode"
fi

# Check for dry-run flag
dry_run=false
if [[ "$ARGUMENTS" == *"--dry-run"* ]]; then
    dry_run=true
    echo "🔍 DRY RUN mode: Will show recommendations without applying"
fi
\`\`\`

## Settings Discovery

**Step 3: Find relevant settings files**

\`\`\`bash
# Always include user-level settings
user_settings="$HOME/.claude/settings.json"
settings_files=()

if [[ -f "$user_settings" ]]; then
    settings_files+=("$user_settings")
    echo "✓ Found user-level settings"
else
    echo "⚠️  No user-level settings found at $user_settings"
fi

# Add mode-specific settings files
case "$mode" in
    global)
        echo "📊 Scanning all profiles for project settings..."

        # Scan all profile directories
        for profile in work pjbeyer play home; do
            profile_dir="$HOME/Projects/$profile"

            if [[ ! -d "$profile_dir" ]]; then
                continue
            fi

            # Find all .claude/settings.json in projects
            while IFS= read -r settings_file; do
                settings_files+=("$settings_file")
            done < <(find "$profile_dir" -name "settings.json" -path "*/.claude/*" -type f 2>/dev/null)
        done

        echo "✓ Found ${#settings_files[@]} settings files total"
        ;;

    project)
        # Check for project-level settings in current directory
        project_settings="./.claude/settings.json"

        if [[ -f "$project_settings" ]]; then
            settings_files+=("$project_settings")
            echo "✓ Found project-level settings"
        else
            echo "ℹ️  No project-level settings in current directory"
        fi
        ;;

    user)
        echo "ℹ️  Analyzing user-level settings only"
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Settings Files to Analyze:"
for file in "${settings_files[@]}"; do
    echo "  - $file"
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
\`\`\`

## Analysis Categories

### Consolidation Analysis

**Step 4: Detect duplicate permissions and consolidation opportunities**

\`\`\`bash
# TODO: Implement in next task
echo "⏳ Consolidation analysis - TODO"
\`\`\`

### Security Analysis

**Step 5: Check for security issues**

\`\`\`bash
# TODO: Implement in next task
echo "⏳ Security analysis - TODO"
\`\`\`

### Migration Analysis

**Step 6: Find migration candidates**

\`\`\`bash
# TODO: Implement in next task
echo "⏳ Migration analysis - TODO"
\`\`\`

### Performance Analysis

**Step 7: Check performance optimizations**

\`\`\`bash
# TODO: Implement in next task
echo "⏳ Performance analysis - TODO"
\`\`\`

### Best Practices

**Step 8: Validate against best practices**

\`\`\`bash
# TODO: Implement in next task
echo "⏳ Best practices analysis - TODO"
\`\`\`

## Priority Classification

**Step 9: Classify recommendations**

\`\`\`bash
# TODO: Implement in next task
echo "⏳ Priority classification - TODO"
\`\`\`

## Interactive Approval

**Step 10: Walk through recommendations**

\`\`\`bash
# TODO: Implement in next task
echo "⏳ Interactive approval - TODO"
\`\`\`

## Settings Modification

**Step 11: Apply approved changes**

\`\`\`bash
# TODO: Implement in next task
echo "⏳ Settings modification - TODO"
\`\`\`

## Documentation Generation

**Step 12: Generate reports and guides**

\`\`\`bash
# TODO: Implement in next task
echo "⏳ Documentation generation - TODO"
\`\`\`

## Summary

**Step 13: Display final summary**

\`\`\`bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Optimization Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Review changes in settings files"
echo "  2. Check documentation at ~/Projects/.workflow/docs/optimization/settings/"
echo "  3. Test your workflows to ensure everything works"
echo ""
\`\`\`
```

**Step 3: Test context detection**

Run from different locations:

```bash
# Test from ~/Projects
cd ~/Projects
/optimize-settings --dry-run
# Expected: "🌍 Running in GLOBAL mode"

# Test from ~/.claude
cd ~/.claude
/optimize-settings --dry-run
# Expected: "👤 Running in USER mode"

# Test from agents-context-system
cd ~/.claude/plugins/cache/agents-context-system
/optimize-settings --dry-run
# Expected: "📁 Running in PROJECT mode"
```

**Step 4: Commit**

```bash
git add skills/optimize-settings/SKILL.md
git commit -m "feat(optimize-settings): add skill structure with context detection"
```

---

## Task 4: Implement Consolidation Analysis

**Files:**
- Modify: `skills/optimize-settings/SKILL.md` (replace Consolidation Analysis section)

**Step 1: Implement consolidation detection**

Replace the "Consolidation Analysis" section with:

```markdown
### Consolidation Analysis

**Step 4: Detect duplicate permissions and consolidation opportunities**

\`\`\`bash
echo "🔍 Running consolidation analysis..."

# Load rules
rules_file="$HOME/.claude/plugins/cache/agents-context-system/config/settings-rules.json"
consolidation_rules=$(jq -r '.consolidation' "$rules_file" 2>/dev/null || echo "{}")

# Arrays to track recommendations
declare -a consolidation_recommendations=()
consolidation_priority=()

# Check for duplicate permissions across files
if [[ ${#settings_files[@]} -gt 1 ]]; then
    echo "  → Checking for duplicate permissions..."

    # Extract all permissions from user-level
    user_permissions=$(jq -r '.permissions.allow[]?' "$user_settings" 2>/dev/null | sort)

    # Check each project settings file
    for settings_file in "${settings_files[@]}"; do
        if [[ "$settings_file" == "$user_settings" ]]; then
            continue
        fi

        project_permissions=$(jq -r '.permissions.allow[]?' "$settings_file" 2>/dev/null | sort)

        # Find duplicates
        while IFS= read -r perm; do
            if echo "$user_permissions" | grep -Fxq "$perm"; then
                consolidation_recommendations+=("Remove duplicate from $(basename $(dirname $(dirname "$settings_file"))): $perm (already in user-level)")
                consolidation_priority+=("MEDIUM")
            fi
        done <<< "$project_permissions"
    done
fi

# Check for wildcard consolidation opportunities
echo "  → Checking for wildcard consolidation..."

# Get all permissions from user settings
all_permissions=$(jq -r '.permissions.allow[]?' "$user_settings" 2>/dev/null)

# Check for patterns that could be consolidated
# Example: Multiple "Skill(agents-*-system:*)" → "Skill(agents-*:*)"
skill_agents_count=$(echo "$all_permissions" | grep -c "Skill(agents-.*:.*)" || true)
if [[ $skill_agents_count -ge 3 ]]; then
    consolidation_recommendations+=("Consolidate $skill_agents_count Skill(agents-...) patterns to Skill(agents-*:*)")
    consolidation_priority+=("MEDIUM")
fi

# Check for dead references (permissions for non-existent paths)
echo "  → Checking for unused additionalDirectories..."

additional_dirs=$(jq -r '.permissions.additionalDirectories[]?' "$user_settings" 2>/dev/null)

while IFS= read -r dir; do
    if [[ -n "$dir" ]]; then
        # Expand ~ to home directory
        expanded_dir="${dir/#\~/$HOME}"

        if [[ ! -d "$expanded_dir" ]]; then
            consolidation_recommendations+=("Remove unused additionalDirectory: $dir (directory doesn't exist)")
            consolidation_priority+=("LOW")
        fi
    fi
done <<< "$additional_dirs"

echo "  ✓ Found ${#consolidation_recommendations[@]} consolidation opportunities"
\`\`\`
```

**Step 2: Test consolidation analysis**

Run:
```bash
cd ~/.claude/plugins/cache/agents-context-system
/optimize-settings --dry-run
```

Expected: Shows consolidation recommendations based on actual settings

**Step 3: Commit**

```bash
git add skills/optimize-settings/SKILL.md
git commit -m "feat(optimize-settings): implement consolidation analysis"
```

---

## Task 5: Implement Security Analysis

**Files:**
- Modify: `skills/optimize-settings/SKILL.md` (replace Security Analysis section)

**Step 1: Implement security checks**

Replace the "Security Analysis" section with:

```markdown
### Security Analysis

**Step 5: Check for security issues**

\`\`\`bash
echo "🔒 Running security analysis..."

# Load security rules
security_rules=$(jq -r '.security' "$rules_file" 2>/dev/null || echo "{}")
overly_permissive=$(echo "$security_rules" | jq -r '.overly_permissive_patterns[]?' 2>/dev/null)
required_denials=$(echo "$security_rules" | jq -r '.required_denials[]?' 2>/dev/null)

declare -a security_recommendations=()
security_priority=()

# Check for overly permissive patterns in allow list
echo "  → Checking for overly permissive patterns..."

user_allows=$(jq -r '.permissions.allow[]?' "$user_settings" 2>/dev/null)

while IFS= read -r permissive_pattern; do
    if echo "$user_allows" | grep -Fq "$permissive_pattern"; then
        security_recommendations+=("HIGH RISK: Overly permissive pattern found: $permissive_pattern")
        security_priority+=("HIGH")
    fi
done <<< "$overly_permissive"

# Check for missing required denials
echo "  → Checking for missing security denials..."

user_denies=$(jq -r '.permissions.deny[]?' "$user_settings" 2>/dev/null)

while IFS= read -r required_denial; do
    if ! echo "$user_denies" | grep -Fq "$required_denial"; then
        security_recommendations+=("Missing security denial: $required_denial")
        security_priority+=("HIGH")
    fi
done <<< "$required_denials"

# Check for contradictions (allow undermines deny)
echo "  → Checking for allow/deny contradictions..."

while IFS= read -r deny_pattern; do
    # Extract the core pattern (e.g., "Read(~/.ssh/id_*)")
    # Check if a broader allow pattern exists
    core_path=$(echo "$deny_pattern" | sed 's/.*(\(.*\)).*/\1/')

    # Simple check: if we deny something specific but allow something broader
    if echo "$user_allows" | grep -q "$(echo "$core_path" | sed 's/\/id_\*/\/\*\*/')"; then
        security_recommendations+=("CONTRADICTION: deny '$deny_pattern' may be undermined by broader allow pattern")
        security_priority+=("HIGH")
    fi
done <<< "$user_denies"

echo "  ✓ Found ${#security_recommendations[@]} security concerns"
\`\`\`
```

**Step 2: Test security analysis**

Run:
```bash
cd ~/.claude/plugins/cache/agents-context-system
/optimize-settings --dry-run
```

Expected: Shows security recommendations

**Step 3: Commit**

```bash
git add skills/optimize-settings/SKILL.md
git commit -m "feat(optimize-settings): implement security analysis"
```

---

## Task 6: Implement Migration Analysis

**Files:**
- Modify: `skills/optimize-settings/SKILL.md` (replace Migration Analysis section)

**Step 1: Implement migration detection**

Replace the "Migration Analysis" section with:

```markdown
### Migration Analysis

**Step 6: Find migration candidates**

\`\`\`bash
echo "🚀 Running migration analysis..."

declare -a migration_recommendations=()
migration_priority=()

# Only meaningful in global mode
if [[ "$mode" == "global" ]]; then
    echo "  → Analyzing permissions across projects..."

    # Count permission frequency across project settings
    declare -A permission_counts

    for settings_file in "${settings_files[@]}"; do
        if [[ "$settings_file" == "$user_settings" ]]; then
            continue  # Skip user-level
        fi

        project_perms=$(jq -r '.permissions.allow[]?' "$settings_file" 2>/dev/null)

        while IFS= read -r perm; do
            if [[ -n "$perm" ]]; then
                permission_counts["$perm"]=$((${permission_counts["$perm"]:-0} + 1))
            fi
        done <<< "$project_perms"
    done

    # Find permissions that appear in 3+ projects
    min_count=3
    user_perms=$(jq -r '.permissions.allow[]?' "$user_settings" 2>/dev/null)

    for perm in "${!permission_counts[@]}"; do
        count=${permission_counts[$perm]}

        if [[ $count -ge $min_count ]]; then
            # Check if already in user-level
            if ! echo "$user_perms" | grep -Fxq "$perm"; then
                migration_recommendations+=("Move to user-level (appears in $count projects): $perm")
                migration_priority+=("MEDIUM")
            fi
        fi
    done

    echo "  ✓ Found ${#migration_recommendations[@]} migration candidates"
else
    echo "  ℹ️  Migration analysis only available in global mode"
fi
\`\`\`
```

**Step 2: Test migration analysis**

Run from global mode:
```bash
cd ~/Projects
/optimize-settings --dry-run
```

Expected: Shows permissions that appear in multiple projects

**Step 3: Commit**

```bash
git add skills/optimize-settings/SKILL.md
git commit -m "feat(optimize-settings): implement migration analysis"
```

---

## Task 7: Implement Performance and Best Practices Analysis

**Files:**
- Modify: `skills/optimize-settings/SKILL.md` (replace Performance and Best Practices sections)

**Step 1: Implement performance analysis**

Replace the "Performance Analysis" section with:

```markdown
### Performance Analysis

**Step 7: Check performance optimizations**

\`\`\`bash
echo "⚡ Running performance analysis..."

declare -a performance_recommendations=()
performance_priority=()

# Check permission ordering (specific should come before general)
echo "  → Analyzing permission ordering..."

user_allows_array=$(jq -r '.permissions.allow[]?' "$user_settings" 2>/dev/null)
prev_was_wildcard=false

while IFS= read -r perm; do
    # Check if this is a specific permission after a wildcard
    if [[ "$prev_was_wildcard" == "true" ]] && [[ "$perm" != *"*"* ]]; then
        performance_recommendations+=("Reorder: Specific permission after wildcard may not be evaluated: $perm")
        performance_priority+=("MEDIUM")
    fi

    # Track if current is wildcard
    if [[ "$perm" == *"*"* ]]; then
        prev_was_wildcard=true
    fi
done <<< "$user_allows_array"

# Check for repeated paths that could use env variables
echo "  → Checking for env variable opportunities..."

# Count path occurrences
declare -A path_counts
while IFS= read -r perm; do
    # Extract paths from permissions
    if [[ "$perm" =~ \(([^)]+)\) ]]; then
        path="${BASH_REMATCH[1]}"

        # Skip if already using env var
        if [[ "$path" != *"$"* ]]; then
            base_path=$(dirname "$path" 2>/dev/null || echo "$path")
            path_counts["$base_path"]=$((${path_counts["$base_path"]:-0} + 1))
        fi
    fi
done <<< "$user_allows_array"

# Suggest env vars for paths used 2+ times
for path in "${!path_counts[@]}"; do
    count=${path_counts[$path]}
    if [[ $count -ge 2 ]]; then
        performance_recommendations+=("Consider env variable for repeated path ($count uses): $path")
        performance_priority+=("LOW")
    fi
done

echo "  ✓ Found ${#performance_recommendations[@]} performance improvements"
\`\`\`
```

**Step 2: Implement best practices check**

Replace the "Best Practices" section with:

```markdown
### Best Practices

**Step 8: Validate against best practices**

\`\`\`bash
echo "✨ Running best practices analysis..."

declare -a bestpractice_recommendations=()
bestpractice_priority=()

# Check for deprecated settings
echo "  → Checking for deprecated settings..."

deprecated_settings=$(jq -r '.deprecated.settings[]?' "$rules_file" 2>/dev/null)

while IFS= read -r deprecated; do
    if jq -e ".$deprecated" "$user_settings" >/dev/null 2>&1; then
        replacement=$(jq -r ".deprecated.replacements.\"$deprecated\"" "$rules_file" 2>/dev/null)
        bestpractice_recommendations+=("DEPRECATED: Remove '$deprecated' - $replacement")
        bestpractice_priority+=("HIGH")
    fi
done <<< "$deprecated_settings"

# Check for plugin configuration issues
echo "  → Validating plugin configuration..."

enabled_plugins=$(jq -r '.enabledPlugins | keys[]?' "$user_settings" 2>/dev/null)

while IFS= read -r plugin; do
    if [[ -n "$plugin" ]]; then
        # Check if plugin directory exists
        plugin_dir="$HOME/.claude/plugins/cache/$plugin"

        if [[ ! -d "$plugin_dir" ]]; then
            bestpractice_recommendations+=("Enabled plugin not found: $plugin (may need installation)")
            bestpractice_priority+=("MEDIUM")
        fi
    fi
done <<< "$enabled_plugins"

echo "  ✓ Found ${#bestpractice_recommendations[@]} best practice issues"
\`\`\`
```

**Step 3: Test analyses**

Run:
```bash
cd ~/.claude/plugins/cache/agents-context-system
/optimize-settings --dry-run
```

Expected: Shows performance and best practice recommendations

**Step 4: Commit**

```bash
git add skills/optimize-settings/SKILL.md
git commit -m "feat(optimize-settings): implement performance and best practices analysis"
```

---

## Task 8: Implement Priority Classification and Recommendation Display

**Files:**
- Modify: `skills/optimize-settings/SKILL.md` (replace Priority Classification section)

**Step 1: Implement priority classification and display**

Replace the "Priority Classification" section with:

```markdown
## Priority Classification and Display

**Step 9: Classify and display all recommendations**

\`\`\`bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Analysis Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Combine all recommendations with priorities
declare -a all_recommendations=()
declare -a all_priorities=()

# Add all categories
for i in "${!consolidation_recommendations[@]}"; do
    all_recommendations+=("${consolidation_recommendations[$i]}")
    all_priorities+=("${consolidation_priority[$i]}")
done

for i in "${!security_recommendations[@]}"; do
    all_recommendations+=("${security_recommendations[$i]}")
    all_priorities+=("${security_priority[$i]}")
done

for i in "${!migration_recommendations[@]}"; do
    all_recommendations+=("${migration_recommendations[$i]}")
    all_priorities+=("${migration_priority[$i]}")
done

for i in "${!performance_recommendations[@]}"; do
    all_recommendations+=("${performance_recommendations[$i]}")
    all_priorities+=("${performance_priority[$i]}")
done

for i in "${!bestpractice_recommendations[@]}"; do
    all_recommendations+=("${bestpractice_recommendations[$i]}")
    all_priorities+=("${bestpractice_priority[$i]}")
done

# Count by priority
high_count=0
medium_count=0
low_count=0

for priority in "${all_priorities[@]}"; do
    case "$priority" in
        HIGH) ((high_count++)) ;;
        MEDIUM) ((medium_count++)) ;;
        LOW) ((low_count++)) ;;
    esac
done

total_count=${#all_recommendations[@]}

if [[ $total_count -eq 0 ]]; then
    echo "✅ No optimization opportunities found!"
    echo "Your settings are well-optimized."
    exit 0
fi

echo "Found $total_count recommendations:"
echo "  🔴 HIGH priority: $high_count (security/high-risk)"
echo "  🟡 MEDIUM priority: $medium_count (optimizations)"
echo "  🟢 LOW priority: $low_count (minor improvements)"
echo ""

# Display HIGH priority items
if [[ $high_count -gt 0 ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔴 HIGH PRIORITY ($high_count recommendations)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    for i in "${!all_recommendations[@]}"; do
        if [[ "${all_priorities[$i]}" == "HIGH" ]]; then
            echo "  • ${all_recommendations[$i]}"
        fi
    done
    echo ""
fi

# Display MEDIUM priority items
if [[ $medium_count -gt 0 ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🟡 MEDIUM PRIORITY ($medium_count recommendations)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    for i in "${!all_recommendations[@]}"; do
        if [[ "${all_priorities[$i]}" == "MEDIUM" ]]; then
            echo "  • ${all_recommendations[$i]}"
        fi
    done
    echo ""
fi

# Display LOW priority items
if [[ $low_count -gt 0 ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🟢 LOW PRIORITY ($low_count recommendations)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    for i in "${!all_recommendations[@]}"; do
        if [[ "${all_priorities[$i]}" == "LOW" ]]; then
            echo "  • ${all_recommendations[$i]}"
        fi
    done
    echo ""
fi
\`\`\`
```

**Step 2: Test recommendation display**

Run:
```bash
cd ~/.claude/plugins/cache/agents-context-system
/optimize-settings --dry-run
```

Expected: Shows all recommendations organized by priority with counts

**Step 3: Commit**

```bash
git add skills/optimize-settings/SKILL.md
git commit -m "feat(optimize-settings): implement priority classification and display"
```

---

## Task 9: Implement Interactive Approval Flow (Dry-Run Exit)

**Files:**
- Modify: `skills/optimize-settings/SKILL.md` (replace Interactive Approval section)

**Step 1: Add dry-run exit and approval framework**

Replace the "Interactive Approval" section with:

```markdown
## Interactive Approval

**Step 10: Walk through recommendations with user approval**

\`\`\`bash
# If dry-run, exit here
if [[ "$dry_run" == "true" ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 DRY RUN Complete"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Run without --dry-run to apply changes interactively."
    exit 0
fi

# Track approved changes
declare -a approved_recommendations=()
declare -a approved_priorities=()

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  INTERACTIVE MODE - Not Yet Implemented"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Interactive approval flow will be implemented in next phase."
echo "This includes:"
echo "  - HIGH priority: Individual approval for each item"
echo "  - MEDIUM priority: Batch approval"
echo "  - LOW priority: Auto-apply with summary"
echo ""
echo "For now, use --dry-run to see recommendations."
\`\`\`
```

**Step 2: Test dry-run completion**

Run:
```bash
cd ~/.claude/plugins/cache/agents-context-system
/optimize-settings --dry-run
```

Expected: Shows all recommendations then exits with "DRY RUN Complete"

**Step 3: Commit**

```bash
git add skills/optimize-settings/SKILL.md
git commit -m "feat(optimize-settings): add dry-run exit and approval framework"
```

---

## Task 10: Add Placeholders for Settings Modification and Documentation

**Files:**
- Modify: `skills/optimize-settings/SKILL.md` (Settings Modification and Documentation sections)

**Step 1: Add comprehensive TODO placeholders**

Replace "Settings Modification" section with:

```markdown
## Settings Modification

**Step 11: Create backup and apply approved changes**

\`\`\`bash
echo "💾 Creating backup..."

# Create backup with timestamp
timestamp=$(date +%Y%m%d-%H%M%S)
backup_file="$user_settings.backup-$timestamp"

cp "$user_settings" "$backup_file"
echo "✓ Backup created: $backup_file"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  SETTINGS MODIFICATION - Not Yet Implemented"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Settings modification will include:"
echo "  - JSON manipulation using jq"
echo "  - Validation after changes"
echo "  - Per-recommendation application"
echo "  - Rollback on error"
echo ""
\`\`\`
```

Replace "Documentation Generation" section with:

```markdown
## Documentation Generation

**Step 12: Generate comprehensive documentation**

\`\`\`bash
# Create documentation directory
docs_dir="$HOME/Projects/.workflow/docs/optimization/settings"
mkdir -p "$docs_dir"

echo "📝 Generating documentation..."

# Create optimization report filename
report_date=$(date +%Y-%m-%d)
report_file="$docs_dir/$report_date-optimization-report.md"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  DOCUMENTATION GENERATION - Not Yet Implemented"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Documentation will include:"
echo "  - Optimization report: $report_file"
echo "  - Best practices guide: $docs_dir/README.md"
echo "  - Before/after comparisons"
echo "  - Rollback instructions"
echo ""
\`\`\`
```

**Step 2: Test placeholder display**

Run:
```bash
cd ~/.claude/plugins/cache/agents-context-system
/optimize-settings --dry-run
```

Expected: Runs through all analysis, shows placeholders for future implementation

**Step 3: Commit**

```bash
git add skills/optimize-settings/SKILL.md
git commit -m "feat(optimize-settings): add placeholders for modification and documentation"
```

---

## Task 11: Update README and Plugin Configuration

**Files:**
- Modify: `README.md`
- Modify: `.claude-plugin/plugin.json`

**Step 1: Add optimize-settings to README**

Find the "Commands" section and add `/optimize-settings` after `/optimize-mcp`:

```markdown
### `/optimize-settings`

Optimize Claude Code settings configuration and management.

\`\`\`bash
# Optimize settings (context-adaptive)
/optimize-settings

# Force specific mode
/optimize-settings --global
/optimize-settings --user-only

# Dry run (show recommendations only)
/optimize-settings --dry-run
\`\`\`

**What it does**:
- Detects context and adapts scope
- Discovers all relevant settings files
- Analyzes: consolidation, security, migration, performance, best practices
- Classifies by priority (HIGH/MEDIUM/LOW)
- Interactive approval flow
- Comprehensive documentation

**Context modes**:
- Global: Scans all profiles/projects
- Project: Analyzes user + current project
- User: User-level settings only
```

Find the "Skills" section and add under "Optimization Skills":

```markdown
- **optimize-settings**: Settings optimization with priority-based recommendations
```

**Step 2: Update plugin.json (if needed)**

Check if plugin.json needs the new skill registered:

```bash
cat .claude-plugin/plugin.json
```

If skills are explicitly listed, add:
```json
{
  "name": "optimize-settings",
  "path": "skills/optimize-settings/SKILL.md"
}
```

**Step 3: Verify documentation**

Run:
```bash
grep -A 5 "optimize-settings" README.md
```

Expected: Shows the new command documentation

**Step 4: Commit**

```bash
git add README.md
git add .claude-plugin/plugin.json  # Only if modified
git commit -m "docs: add optimize-settings command to README and plugin config"
```

---

## Task 12: End-to-End Integration Testing

**Files:**
- Test in multiple contexts

**Step 1: Test global mode**

```bash
cd ~/Projects
/optimize-settings --dry-run
```

**Expected output:**
- "🌍 Running in GLOBAL mode"
- Scans all profiles
- Shows recommendations from all categories
- Counts HIGH/MEDIUM/LOW priorities
- Exits with "DRY RUN Complete"

**Step 2: Test project mode**

```bash
cd ~/.claude/plugins/cache/agents-context-system
/optimize-settings --dry-run
```

**Expected output:**
- "📁 Running in PROJECT mode"
- Analyzes user + project settings
- Shows relevant recommendations
- Exits cleanly

**Step 3: Test user mode**

```bash
cd ~/.claude
/optimize-settings --dry-run
```

**Expected output:**
- "👤 Running in USER mode"
- Analyzes only user-level settings
- Shows recommendations
- Exits cleanly

**Step 4: Test mode overrides**

```bash
cd ~/.claude/plugins/cache/agents-context-system
/optimize-settings --global --dry-run
```

**Expected output:**
- "🔧 Override: Forced GLOBAL mode"
- Runs in global mode despite being in project directory

**Step 5: Verify error handling**

```bash
# Test with no settings file
mv ~/.claude/settings.json ~/.claude/settings.json.tmp
/optimize-settings --dry-run
mv ~/.claude/settings.json.tmp ~/.claude/settings.json
```

**Expected output:**
- "⚠️ No user-level settings found"
- Graceful handling, no crash

**Step 6: Document test results**

If all tests pass, commit:

```bash
git commit --allow-empty -m "test: verify optimize-settings end-to-end functionality

Verified:
- Context detection (global/project/user)
- Mode overrides (--global, --user-only, --dry-run)
- All analysis categories produce recommendations
- Priority classification working
- Error handling for missing files
- Clean exit in all modes

Ready for phase 2: interactive approval and settings modification"
```

---

## Task 13: Update GitHub Issue and Create Phase 2 Plan

**Files:**
- Update issue #2
- Create phase 2 plan document

**Step 1: Document Phase 1 completion**

Add comment to issue #2:

```markdown
## Phase 1 Complete ✅

Implemented core analysis and recommendation engine for `/optimize-settings` command.

### What Works
- ✅ Context-adaptive behavior (global/project/user modes)
- ✅ Settings file discovery
- ✅ Five analysis categories:
  - Consolidation (duplicates, wildcards, unused paths)
  - Security (overly permissive, missing denials, contradictions)
  - Migration (cross-project patterns)
  - Performance (ordering, env vars)
  - Best Practices (deprecated settings, plugin validation)
- ✅ Priority classification (HIGH/MEDIUM/LOW)
- ✅ Dry-run mode for safe preview
- ✅ Comprehensive display of recommendations

### Phase 2 - To Do
- ⏳ Interactive approval flow (HIGH individual, MEDIUM batch, LOW auto)
- ⏳ Settings file modification with backup
- ⏳ Documentation generation (reports, best practices guide)
- ⏳ Rollback functionality

### Testing
Tested in all three modes with real settings. Analysis engine produces accurate recommendations.

### Files Changed
- `config/settings-rules.json` - Analysis rules
- `commands/optimize-settings.md` - Command entry point
- `skills/optimize-settings/SKILL.md` - Main skill implementation
- `README.md` - Documentation

### Next Steps
Create Phase 2 implementation plan for interactive mode and settings modification.
```

**Step 2: Create Phase 2 plan outline**

Create `docs/plans/2025-11-20-optimize-settings-phase2.md`:

```markdown
# Optimize Settings - Phase 2 Implementation Plan

**Goal:** Complete `/optimize-settings` with interactive approval, settings modification, and comprehensive documentation.

**Prerequisites:** Phase 1 complete (analysis and recommendations working)

## Phase 2 Tasks

1. **Interactive Approval - HIGH Priority**
   - Individual approval for each HIGH item
   - Show detailed explanation per item
   - Allow skip/decline with tracking

2. **Interactive Approval - MEDIUM Priority**
   - Batch display with grouping
   - Single approval for batch
   - Option to expand and see details

3. **Interactive Approval - LOW Priority**
   - Auto-apply with summary
   - List what was applied
   - No approval needed

4. **Settings Modification**
   - JSON manipulation using jq
   - Validate after each change
   - Rollback on error
   - Track applied changes

5. **Documentation Generation**
   - Optimization report with before/after
   - Update best practices guide
   - Track optimization history
   - Rollback instructions

6. **Integration Testing**
   - Test full flow end-to-end
   - Verify rollback works
   - Test with various settings
   - Validate documentation output

**Start Phase 2:** After Phase 1 is merged and tested in production
```

**Step 3: Commit documentation**

```bash
git add docs/plans/2025-11-20-optimize-settings-phase2.md
git commit -m "docs: add Phase 2 implementation plan for optimize-settings

Phase 1 delivers:
- Core analysis engine
- Recommendation generation
- Priority classification
- Dry-run preview

Phase 2 will add:
- Interactive approval
- Settings modification
- Documentation generation
- Complete workflow"
```

---

## Completion

**Phase 1 implementation is complete!**

The `/optimize-settings` command now:
- ✅ Detects context and adapts scope
- ✅ Discovers settings files
- ✅ Analyzes across 5 categories
- ✅ Classifies recommendations by priority
- ✅ Displays comprehensive recommendations
- ✅ Supports dry-run mode

**Ready for:**
- Testing with real settings
- User feedback on recommendations
- Phase 2 planning (interactive mode)

**Test it:**
```bash
cd ~/Projects
/optimize-settings --dry-run
```
