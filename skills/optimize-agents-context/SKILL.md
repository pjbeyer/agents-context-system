---
name: optimize-agents-context
description: Analyze and optimize AGENTS.md files across hierarchy for token efficiency, redundancy detection, and hierarchical correctness. Masters context optimization.
---

# AGENTS.md Context Optimization Skill

Optimize AGENTS.md files across the hierarchy (global/profile/project/agent) for token efficiency while preserving essential information.

## Target Token Budgets

- **Global AGENTS.md**: 8-12k characters
- **Profile AGENTS.md**: 5-8k characters
- **Project AGENTS.md**: 4-6k characters
- **Agent AGENTS.md**: 2-6k characters (profile-dependent)

## Optimization Process

### Step 1: Discovery and Analysis

**Find all AGENTS.md files**:
```bash
find ~/Projects -name "AGENTS.md" -type f
```

**Measure current state**:
- Character count per file
- Token estimation (chars ÷ 4 approximate)
- Hierarchy level identification
- Cross-level redundancy check

### Step 2: Redundancy Detection

**Check for duplication across hierarchy**:
- Global content duplicated in profiles
- Profile content duplicated in projects
- Parent context repeated in children
- Cross-references vs duplication

**Pattern**: Content should exist at exactly one level, referenced from below

### Step 3: Content Classification

For each section, classify as:
- **Essential**: Keep in AGENTS.md (purpose, capabilities, routing)
- **Detailed**: Extract to docs/ (procedures, examples, background)
- **Redundant**: Remove or reference parent level

**Decision Framework**: "Does an AI agent need this for routing, coordination, or tool access? If no, extract."

### Step 4: Extract to /docs/

Move detailed content:
- **Procedures** → docs/workflows/
- **Examples** → docs/examples/
- **Background** → docs/architecture/
- **Lists** → docs/reference/
- **Historical** → docs/history/

Replace with:
```markdown
[One-line summary]

See: docs/[category]/[file].md
```

### Step 5: Consolidate and Simplify

**Content reduction techniques**:
- Prose → bullet lists
- Long descriptions → tables
- Multiple similar → grouped categories
- Verbose → concise phrases

**Before** (200 tokens):
```markdown
- Feature 1: This comprehensive feature provides...
- Feature 2: This powerful feature enables...
```

**After** (60 tokens):
```markdown
Features: [Feature 1], [Feature 2], [Feature 3]

Details: docs/features.md
```

### Step 6: Apply Hierarchy Principles

**Reference, don't duplicate**:
```markdown
# Profile AGENTS.md (BEFORE - duplicated)
Git configuration: [detailed 500-token explanation copied from global]

# Profile AGENTS.md (AFTER - referenced)
Git configuration: See global AGENTS.md
```

**Keep parent context accessible**:
- Children can reference parents
- Parents don't reference children
- Siblings can cross-reference

### Step 7: Verify and Measure

**Verification checklist**:
- ✓ Within token budget
- ✓ No information lost (accessible via references)
- ✓ No duplication across hierarchy
- ✓ Essential context present
- ✓ Clear references to extracted content
- ✓ Hierarchy principles followed

**Measure results**:
- Before/after character counts
- Token savings achieved
- Files created in docs/
- Cross-references added

## MCP Tool Discovery

**Identify MCP tools to document**:
```bash
# Check configured MCP servers
cat ~/.claude/mcp.json

# Find MCP tool usage patterns
grep -r "mcp__" ~/.claude/
```

**Document in appropriate level**:
- Cross-profile tools → Global
- Profile-specific → Profile
- Project-specific → Project

**Format**:
```markdown
## MCP Tools

| Tool | Purpose | Profile |
|------|---------|---------|
| tool-name | [Brief] | [Profiles using] |

See: docs/mcp/tool-registry.md
```

## Profile-Specific Standards

### pjbeyer Profile
- Professional quality: Comprehensive but efficient
- Client-focused: Clear deliverable documentation
- Test coverage: 80%+ documented

### work Profile
- Enterprise focus: Security and compliance first
- Slim documentation: 3-5k target for AGENTS.md
- Notion primary: Team collaboration docs in Notion

### play Profile
- Experimental: Minimal overhead
- Flexible quality: Adapt to learning goals
- Quick iteration: Don't over-document experiments

### home Profile
- Practical: Task-oriented documentation
- Accessible: Simple, clear language
- Family-friendly: Non-technical where possible

## Optimization History

Track optimizations in `docs/optimization/history.md`:
```markdown
## 2025-11-11: Global AGENTS.md Optimization

**Before**: 15,234 characters
**After**: 9,847 characters
**Savings**: 5,387 characters (35% reduction)

**Changes**:
- Extracted MCP tool details to docs/mcp/tool-registry.md
- Consolidated profile descriptions
- Removed redundant git configuration (referenced from global)
- Created docs/setup/ for detailed procedures

**Files Created**: 8 new documentation files
**Next Review**: 2026-04-11 (quarterly)
```

## Quality Checklist

Before completing optimization:
- ✓ All AGENTS.md files measured
- ✓ Hierarchy analyzed for redundancy
- ✓ Detailed content extracted to docs/
- ✓ Clear references added
- ✓ Token budgets met
- ✓ No information lost
- ✓ Hierarchy principles followed
- ✓ Profile standards respected
- ✓ Optimization history updated

## Workflow Integration

After detecting budget violations, offer to create workflow issues:

```bash
# After analysis completes
echo ""
echo "Budget violations detected. Create workflow issues? (y/n)"
```

**Use AskUserQuestion tool:**
- Question: "Create workflow issues for budget violations?"
- Options:
  - yes: "Create tracking issues"
  - no: "Skip (handle manually)"

**If yes, for each violation:**
```bash
# Extract violation details
file_path="[path from detect-budget-violations.sh]"
current_size="[size from violation output]"
max_size="[budget from violation output]"
over_by="[overage from violation output]"

# Generate recommendations based on file analysis
recommendations="Based on content analysis:
- Extract detailed procedures to docs/workflows/
- Move verbose descriptions to docs/reference/
- Remove duplication from parent AGENTS.md"

# Call issue creation script
~/.claude/plugins/cache/agents-documentation-suite/scripts/create-optimization-issue.sh \
    "$file_path" "$current_size" "$max_size" "$recommendations"
```

**When to create issues:**
- User confirms with 'y'
- More than 2 violations detected
- Violation is >20% over budget

**Issue tracking:**
- Created in project repository
- Labels: `documentation`, `optimization`
- Linked to analysis report in `docs/optimization/`

## Integration

This skill can be invoked by:
- `/optimize-agents` command
- Quarterly documentation reviews
- Post-major-changes optimization
- Cross-profile analysis workflows
- agents-documentation-suite (for machine doc writing)
