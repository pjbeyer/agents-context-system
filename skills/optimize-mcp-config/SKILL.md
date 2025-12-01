---
name: optimize-mcp-config
description: Analyze and optimize MCP server configuration, documentation, and integration patterns across profiles. Masters MCP setup efficiency.
---

# MCP Configuration Optimization Skill

Optimize MCP (Model Context Protocol) server configuration and documentation across profiles for efficiency and clarity.

## Optimization Goals

1. **Configuration Clarity**: Clear, maintainable MCP server configs
2. **Documentation Efficiency**: Token-optimized MCP documentation
3. **Hierarchy Correctness**: Right information at right level
4. **Integration Validation**: Working, tested MCP integrations

## Optimization Process

### Step 1: Configuration Discovery

**Find all MCP configurations**:
```bash
# Find .mcp.json files
find ~/Projects -name ".mcp.json" -maxdepth 3

# Check settings
find ~/Projects -name "settings.local.json" -path "*/.claude/*"
```

**Analyze server inventory**:
- Count MCP servers per profile
- Identify shared vs profile-specific servers
- Check for incomplete configurations (missing PAT, etc.)
- Verify naming conventions

### Step 2: Documentation Structure Review

**Check documentation hierarchy**:

**Root Level** (`~/Projects/docs/mcp/`):
- ✅ Cross-profile patterns, global tool registry, server comparison
- ❌ Profile-specific configs, team patterns

**Profile Level** (`{profile}/docs/mcp/`):
- ✅ Profile-specific configs, tool usage patterns
- ❌ General MCP protocol info, other profile details

**Project Level** (`{project}/docs/mcp/`):
- ✅ Project-specific MCP integrations only
- ❌ General patterns, duplicate content

### Step 3: Token Efficiency Analysis

**Measure MCP documentation**:
```bash
# Get character counts
find ~/Projects -path "*/docs/mcp/*.md" -exec wc -c {} + | sort -rn
```

**Optimization targets**:
- Root MCP docs: < 10k characters total
- Profile MCP docs: < 5k characters each
- Extract detailed examples to separate files
- Use tables for server comparisons

### Step 4: Content Classification

For each MCP documentation section:
- **Essential**: Server list, basic config, common patterns
- **Detailed**: Extensive examples, troubleshooting procedures
- **Redundant**: Info duplicated from other levels

**Extract detailed content**:
- Setup procedures → docs/mcp/setup/
- Troubleshooting → docs/mcp/troubleshooting/
- Examples → docs/mcp/examples/
- Server-specific → docs/mcp/servers/

### Step 5: Server Documentation Pattern

**Optimal MCP tool registry format**:
```markdown
## MCP Tools Registry

| Server | Purpose | Profiles | Status |
|--------|---------|----------|--------|
| notion | Team collaboration | work, pjbeyer | Active |
| github | Code management | all | Active |
| jira | Issue tracking | work | Active |

### Configuration

See: docs/mcp/setup/[server-name].md

### Common Patterns

See: docs/mcp/examples/[use-case].md
```

### Step 6: Permission Documentation

**Document tool permissions**:
```markdown
## Auto-Approved Tools

Tools that don't require approval (from settings.local.json):
- Bash(find:*)
- Bash(ls:*)
- Read(~/.claude/**)
- mcp__Notion__notion-search

See: docs/mcp/permissions.md for complete list
```

### Step 7: Integration Validation

**Test key integrations**:
- Verify servers start correctly
- Test common tool usage patterns
- Check authentication still valid
- Verify error handling documented

**Document validation status**:
```markdown
## Server Health

Last validated: 2025-11-11

| Server | Status | Notes |
|--------|--------|-------|
| notion | ✅ Working | API key valid |
| github | ✅ Working | PAT expires 2026-01-01 |
| jira | ⚠️ Needs config | Update URL |
```

### Step 8: Cross-Profile Patterns

**Identify shared patterns**:
- Servers used in multiple profiles
- Common usage patterns
- Shared authentication approaches
- Similar configuration needs

**Extract to global**:
```markdown
# Global MCP Patterns

## Authentication Patterns
- Environment variables for secrets
- Profile-specific .env files
- Never commit credentials

## Server Naming
- Use official server names
- Consistent casing
- Profile prefix if needed

See profiles for specific implementations.
```

## Profile-Specific Considerations

### pjbeyer Profile
- Client-focused tools (notion, github, google)
- Professional authentication (separate credentials)
- Minimal overhead (only needed tools)

### work Profile
- Enterprise tools (Jira, Flex GitHub, DryRun)
- Team collaboration (Notion databases)
- Security-first (audit logging, access control)

### play Profile
- Experimental tools (try new servers)
- Minimal configuration
- Easy teardown/rebuild

### home Profile
- Family tools (calendar, tasks)
- Simple setup
- Privacy-focused

## Optimization Patterns

### Configuration Simplification
**Before** (verbose):
```json
{
  "mcpServers": {
    "notion-integration-server": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_API_KEY": "secret_xyz123..."
      }
    }
  }
}
```

**After** (clean):
```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_API_KEY": "${NOTION_API_KEY}"
      }
    }
  }
}
```
(Secret in .env file, not config)

### Documentation Consolidation
**Before** (duplicated across profiles):
```markdown
# pjbeyer/docs/mcp/notion.md (500 tokens)
[Full Notion setup and usage guide]

# work/docs/mcp/notion.md (500 tokens)
[Same full Notion setup and usage guide]
```

**After** (referenced):
```markdown
# ~/Projects/docs/mcp/servers/notion.md (500 tokens)
[Full Notion setup and usage guide]

# pjbeyer/docs/mcp/notion.md (50 tokens)
Notion configuration: See global docs/mcp/servers/notion.md
Profile-specific databases: [list]

# work/docs/mcp/notion.md (50 tokens)
Notion configuration: See global docs/mcp/servers/notion.md
Profile-specific databases: [list]
```

## Quality Checklist

Before completing optimization:
- ✓ All .mcp.json files analyzed
- ✓ Server inventory complete
- ✓ Documentation hierarchy correct
- ✓ Token budgets met
- ✓ No duplication across profiles
- ✓ Essential configs preserved
- ✓ Detailed docs extracted
- ✓ Integration validation done
- ✓ Permissions documented
- ✓ Cross-profile patterns identified

## Integration

This skill can be invoked by:
- `/optimize-mcp` command
- MCP configuration reviews
- New server addition workflows
- Cross-profile MCP analysis
- phil-ai-docs (for MCP documentation)
