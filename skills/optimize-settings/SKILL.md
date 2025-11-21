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

```bash
cwd=$(pwd)
home_normalized="$HOME"

# Detect mode based on current directory
if [[ "$cwd" == "$home_normalized" ]] || \
   [[ "$cwd" == "$home_normalized/Projects" ]] || \
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
```

**Step 2: Check for mode override flags**

```bash
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
```

## Settings Discovery

**Step 3: Find relevant settings files**

```bash
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
```

## Analysis Categories

### Consolidation Analysis

**Step 4: Detect duplicate permissions and consolidation opportunities**

```bash
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
```

### Security Analysis

**Step 5: Check for security issues**

```bash
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
```

### Migration Analysis

**Step 6: Find migration candidates**

```bash
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
```

### Performance Analysis

**Step 7: Check performance optimizations**

```bash
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
```

### Best Practices

**Step 8: Validate against best practices**

```bash
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
```

## Priority Classification

**Step 9: Classify recommendations**

```bash
# TODO: Implement in next task
echo "⏳ Priority classification - TODO"
```

## Interactive Approval

**Step 10: Walk through recommendations**

```bash
# TODO: Implement in next task
echo "⏳ Interactive approval - TODO"
```

## Settings Modification

**Step 11: Apply approved changes**

```bash
# TODO: Implement in next task
echo "⏳ Settings modification - TODO"
```

## Documentation Generation

**Step 12: Generate reports and guides**

```bash
# TODO: Implement in next task
echo "⏳ Documentation generation - TODO"
```

## Summary

**Step 13: Display final summary**

```bash
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
```
