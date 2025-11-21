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
# TODO: Implement in next task
echo "⏳ Consolidation analysis - TODO"
```

### Security Analysis

**Step 5: Check for security issues**

```bash
# TODO: Implement in next task
echo "⏳ Security analysis - TODO"
```

### Migration Analysis

**Step 6: Find migration candidates**

```bash
# TODO: Implement in next task
echo "⏳ Migration analysis - TODO"
```

### Performance Analysis

**Step 7: Check performance optimizations**

```bash
# TODO: Implement in next task
echo "⏳ Performance analysis - TODO"
```

### Best Practices

**Step 8: Validate against best practices**

```bash
# TODO: Implement in next task
echo "⏳ Best practices analysis - TODO"
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
