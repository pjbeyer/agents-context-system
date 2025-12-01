# phil-ai-context

Claude Code plugin for hierarchical AGENTS.md optimization, MCP configuration, and smart context loading.

## Purpose

Optimize AI context across development environments (global/profile/project/agent), reduce token usage up to 40%, provide intelligent context loading.

## Architecture

| Component | Purpose |
|-----------|---------|
| Hierarchy System | 4-level organization, profile/level detection |
| Optimization Engine | Token-efficient AGENTS.md, MCP config, settings |
| Context Loading | Smart loading by hierarchy level |
| Task Management | Hierarchy-aware task tracking |

**Stack**: Bash scripts, JSON config, Claude Code plugin system

## Commands

| Command | Purpose |
|---------|---------|
| `/optimize-agents` | AGENTS.md token optimization |
| `/optimize-mcp` | MCP server configuration |
| `/optimize-settings` | Claude Code settings (HIGH/MED/LOW priority) |
| `/add-task` | Hierarchy-aware task creation |

## Skills

| Category | Skills |
|----------|--------|
| Optimization | optimize-agents-context, optimize-mcp-config, optimize-settings |
| Hierarchy | detect-profile, detect-level, navigate-hierarchy |
| Context | load-agents-context, analyze-context-usage |
| Tasks | add-task, manage-tasks |

## Token Budgets

| Level | Target | Loading Strategy |
|-------|--------|------------------|
| Global | 8-12k | Minimal (global only) |
| Profile | 5-8k | Profile → global |
| Project | 4-6k | Project → profile → global |
| Agent | 2-6k | Agent → project → profile (skip global = 40% savings) |

## Integration

- **phil-ai-docs**: Token budget enforcement
- **phil-ai-learning**: Context-aware learning storage
- **workflow system**: Profile detection, task routing

## Profile Standards

| Profile | Focus | Budget |
|---------|-------|--------|
| pjbeyer | Client-focused | 4-6k |
| work | Security-first | 3-5k |
| play | Experimental | 2-4k |
| home | Task-oriented | 2-4k |

## Config Files

- `hierarchy-config.json`: Budgets, loading strategies
- `profile-definitions.json`: Profile standards, detection
- `context-rules.json`: Optimization rules
- `settings-rules.json`: Security patterns, priorities

---
**Version**: 1.0.6 | **Status**: Active
