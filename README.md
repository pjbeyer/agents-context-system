# phil-ai-context

Optimize AGENTS.md files, manage MCP configuration, and load context efficiently.

## Quick Start for New Users

**Pre-approve skills for faster workflow**: Add this to your Claude Code settings:

```json
{
  "approvedSkills": [
    "phil-ai-context:optimize-agents-context",
    "phil-ai-context:optimize-mcp-config",
    "phil-ai-context:add-task"
  ]
}
```

**Benefits**: Commands like `/optimize-agents` will run without prompting.

## Features

- **AGENTS.md Optimization**: Token-efficient context files with hierarchy awareness
- **Smart Context Loading**: Load only relevant context based on hierarchy level
- **MCP Configuration Management**: Optimize MCP server setup and documentation
- **Hierarchy Management**: Detect and navigate global/profile/project/agent levels
- **Profile-Aware**: Respect different standards across pjbeyer/work/play/home
- **Task Management**: Hierarchy-aware task tracking and management

## Installation

```bash
/plugin marketplace add pjbeyer/phil-ai
/plugin install phil-ai-context@phil-ai
```

## Commands

### `/optimize-agents`

Optimize AGENTS.md files across hierarchy for token efficiency.

```bash
# Optimize all AGENTS.md files
/optimize-agents
```

**What it does**:
- Discovers all AGENTS.md files in hierarchy
- Measures character/token usage
- Detects redundancy across levels
- Extracts detailed content to docs/
- Provides optimization recommendations
- Tracks savings achieved

**Target budgets**:
- Global: 8-12k characters
- Profile: 5-8k characters
- Project: 4-6k characters
- Agent: 2-6k characters

### `/optimize-mcp`

Optimize MCP server configuration and documentation.

```bash
# Optimize MCP setup
/optimize-mcp
```

**What it does**:
- Discovers all .mcp.json configurations
- Inventories MCP servers per profile
- Analyzes documentation hierarchy
- Identifies redundant MCP docs
- Validates integrations
- Documents cross-profile patterns

### `/optimize-settings`

Optimize Claude Code settings configuration and management.

```bash
# Optimize settings (context-adaptive)
/optimize-settings

# Force specific mode
/optimize-settings --global
/optimize-settings --user-only

# Dry run (show recommendations only)
/optimize-settings --dry-run
```

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

### `/add-task`

Add tasks to hierarchy-aware task management.

```bash
# Add task at current level
/add-task
```

**Task hierarchy**:
- **Global tasks**: Cross-profile improvements
- **Profile tasks**: Profile-specific work
- **Project tasks**: Project features and fixes
- **Agent tasks**: Agent improvements

## Skills

### Optimization Skills (3)
- **optimize-agents-context**: AGENTS.md optimization and token efficiency
- **optimize-mcp-config**: MCP configuration and documentation optimization
- **optimize-settings**: Settings optimization with priority-based recommendations

### Hierarchy Skills (3)
- **detect-profile**: Detect current profile (pjbeyer/work/play/home/global)
- **detect-level**: Detect hierarchy level (global/profile/project/agent)
- **navigate-hierarchy**: Navigate between levels, find parents/children

### Context Skills (2)
- **load-agents-context**: Smart context loading based on level
- **analyze-context-usage**: Analyze token usage and identify optimizations

### Task Skills (2)
- **add-task**: Add task to appropriate hierarchy level
- **manage-tasks**: Manage tasks across hierarchy

## Hierarchical Organization

### Hierarchy Levels

**Global** (`~/Projects`):
- Cross-profile patterns, environment setup, profile management

**Profile** (`~/Projects/{profile}`):
- Profile philosophy, standards, tech stack, workflows

**Project** (`~/Projects/{profile}/{project}`):
- Project architecture, agent registry, routing, integrations

**Agent** (`~/Projects/{profile}/{project}/agents/{agent}`):
- Agent specification, workflows, integration points, sub-agents

### Smart Context Loading

Load only relevant AGENTS.md files based on current level:

**Agent Level**:
- Load: agent → project → profile (skip global)
- **Token savings**: 40% (15k vs 25k chars)

**Project Level**:
- Load: project → profile → global
- **Full context** for cross-profile work

**Profile Level**:
- Load: profile → global
- **Two levels** for profile work

**Global Level**:
- Load: global only
- **Minimal** for global operations

## Profile-Specific Standards

### pjbeyer Profile
- **Quality**: Professional, client-focused
- **Docs**: Comprehensive but efficient (4-6k chars)
- **Tests**: 80%+ coverage

### work Profile
- **Quality**: Enterprise, security-first
- **Docs**: Slim (3-5k chars target)
- **Tests**: 90%+ for critical paths

### play Profile
- **Quality**: Quick iteration, experimental
- **Docs**: Flexible (2-4k chars)
- **Tests**: Minimal

### home Profile
- **Quality**: Practical, accessible
- **Docs**: Simple (2-4k chars)
- **Tests**: Task-oriented

## Token Efficiency Strategies

### Extract to /docs/
- **Procedures** → docs/workflows/
- **Examples** → docs/examples/
- **Background** → docs/architecture/
- **Detailed lists** → docs/reference/

### Reference, Don't Duplicate
```markdown
# Profile AGENTS.md (BEFORE)
Git configuration: [500 chars duplicated from global]

# Profile AGENTS.md (AFTER)
Git configuration: See global AGENTS.md
```

### Content Consolidation
```markdown
# BEFORE (200 tokens)
- Feature 1: This comprehensive feature provides...
- Feature 2: This powerful feature enables...

# AFTER (60 tokens)
Features: [Feature 1], [Feature 2], [Feature 3]

Details: docs/features.md
```

## Configuration

Three configuration files define behavior:

### `hierarchy-config.json`
- Token budgets per level
- Loading strategies
- Hierarchy principles

### `profile-definitions.json`
- Profile purposes and standards
- Detection rules
- Git config locations

### `context-rules.json`
- Optimization rules
- Content classification
- MCP rules

## Integration with Other Plugins

### phil-ai-docs
- Uses context-system for AGENTS.md optimization
- Machine documentation writing with token budgets
- Hierarchical documentation coordination

### phil-ai-learning
- Learnings captured at appropriate hierarchy level
- Context-aware learning storage

## Philosophy

### Hierarchical Organization
Information exists at exactly one level. Lower levels reference, not duplicate, higher levels.

### Token Efficiency
For machine-readable docs, every token counts. Extract detail to /docs/, keep essentials in AGENTS.md.

### Profile-Aware
Different profiles have different standards. Respect them.

### Smart Loading
Load only what's needed. Agent-level work doesn't need global context.

## Development

### Structure
```
phil-ai-context/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── optimization/     # 2 skills
│   ├── hierarchy/        # 3 skills
│   ├── context/          # 2 skills
│   └── tasks/            # 2 skills
├── commands/
│   ├── optimize-agents.md
│   ├── optimize-mcp.md
│   └── add-task.md
├── config/
│   ├── hierarchy-config.json
│   ├── profile-definitions.json
│   └── context-rules.json
└── docs/
    └── README.md
```

### Testing Locally

1. Create development marketplace
2. Install for testing
3. Restart Claude Code and test commands

## Examples

### Optimize AGENTS.md Files
```bash
cd ~/Projects/work
/optimize-agents

# Output:
# Analyzing 23 AGENTS.md files...
# Total: 112,334 chars
# Over budget: 8 files
# Potential savings: 31% (35,000 chars)
#
# Recommendations:
# 1. Extract MCP details to docs/mcp/ (save 15k)
# 2. Reference global git config (save 2k)
# 3. Move examples to docs/examples/ (save 18k)
```

### Smart Context Loading
```bash
# Working at agent level
cd ~/Projects/work/security-agents/agents/scanner

# Context loaded:
# - agent/AGENTS.md (3k chars)
# - project/AGENTS.md (5k chars)
# - profile/AGENTS.md (7k chars)
# Total: 15k chars (vs 25k if all levels loaded)
```

### Add Task
```bash
cd ~/Projects/work/security-project
/add-task

# Creates: ~/Projects/work/security-project/docs/tasks/project.md
# With proper format and context awareness
```

## License

MIT License

## Repository

https://github.com/pjbeyer/phil-ai-context
