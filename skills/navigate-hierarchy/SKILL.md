---
name: navigate-hierarchy
description: Navigate between hierarchy levels, locate parent/child contexts, and manage cross-level references.
---

# Hierarchy Navigation Skill

Navigate the hierarchical structure to find parent contexts, child items, and cross-level references.

## Navigation Operations

### Find Parent Contexts

**From current level, find parents**:
```bash
# Current: project level
current="/Users/pjbeyer/Projects/work/my-project"

# Parent profile
profile=$(dirname "$current")
# /Users/pjbeyer/Projects/work

# Parent global
global=$(dirname "$profile")
# /Users/pjbeyer/Projects
```

### Find Child Items

**From current level, find children**:
```bash
# From profile, find all projects
find "$profile_path" -maxdepth 1 -type d -not -path "$profile_path"

# From project, find all agents
find "$project_path/agents" -maxdepth 1 -type d 2>/dev/null
```

### Locate AGENTS.md Files

**Find AGENTS.md at each level**:
```bash
# Function to find AGENTS.md in hierarchy
find_agents_md() {
  local current="$1"
  local found=()

  # Check current level
  [ -f "$current/AGENTS.md" ] && found+=("$current/AGENTS.md")

  # Walk up to parents
  while [ "$current" != "/Users/pjbeyer/Projects" ]; do
    current=$(dirname "$current")
    [ -f "$current/AGENTS.md" ] && found+=("$current/AGENTS.md")
  done

  # Return array
  printf '%s\n' "${found[@]}"
}
```

## Cross-Level References

### Reference Parent Content

**Pattern for child referencing parent**:
```markdown
## Git Configuration

See: ../AGENTS.md (profile level)

## Global Standards

See: ../../AGENTS.md (global level)
```

### Reference Sibling Content

**Pattern for cross-referencing at same level**:
```markdown
## Related Projects

- See: ../other-project/AGENTS.md
- See: ../another-project/docs/
```

## Path Resolution

### Relative to Absolute

```bash
# Convert relative reference to absolute
resolve_path() {
  local ref="$1"
  local current="$2"

  cd "$current" && realpath "$ref"
}

# Example
resolve_path "../AGENTS.md" "/Users/pjbeyer/Projects/work/project"
# Returns: /Users/pjbeyer/Projects/work/AGENTS.md
```

### Find Common Ancestor

```bash
# Find lowest common ancestor of two paths
common_ancestor() {
  local path1="$1"
  local path2="$2"

  # Implementation finds shared parent
  # Returns path to common ancestor
}
```

## Navigation Patterns

### Load Parent Chain

```bash
# Load all AGENTS.md files from current to root
load_parent_chain() {
  local current="$PWD"
  local chain=()

  while [[ "$current" == /Users/pjbeyer/Projects* ]]; do
    if [ -f "$current/AGENTS.md" ]; then
      chain+=("$current/AGENTS.md")
    fi
    [ "$current" = "/Users/pjbeyer/Projects" ] && break
    current=$(dirname "$current")
  done

  printf '%s\n' "${chain[@]}"
}
```

### Find Siblings

```bash
# Find sibling projects/agents at same level
find_siblings() {
  local current="$PWD"
  local parent=$(dirname "$current")

  find "$parent" -maxdepth 1 -type d -not -path "$parent" -not -path "$current"
}
```

## Integration

Invoked by:
- Context loading (load-agents-context)
- Optimization (optimize-agents)
- Documentation coordination (phil-ai-docs)
- Cross-reference validation
