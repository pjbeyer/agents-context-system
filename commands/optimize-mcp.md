# Optimize MCP - Configuration and Documentation

Analyze and optimize MCP server configuration, documentation hierarchy, and integration patterns across profiles.

## Invocation

Use and follow the `optimize-mcp-config` skill exactly as written.

## Usage

From any location in your project hierarchy:

```bash
/optimize-mcp
```

The skill will:
1. Discover all .mcp.json configurations
2. Inventory MCP servers per profile
3. Analyze documentation hierarchy
4. Identify redundant MCP docs
5. Extract detailed content
6. Validate integrations
7. Document cross-profile patterns
8. Generate optimization report

## Optimization Areas

### Configuration
- Clean, maintainable .mcp.json files
- Environment variables for secrets
- Consistent server naming
- Profile-specific vs shared servers

### Documentation
- Token-efficient MCP docs
- Proper hierarchy (global/profile/project)
- No duplication across levels
- Clear server registry

### Integration
- Working, tested servers
- Valid authentication
- Error handling documented
- Permission documentation

## Documentation Hierarchy

**Root** (`~/Projects/docs/mcp/`):
- Cross-profile patterns
- Global tool registry
- Server comparison

**Profile** (`{profile}/docs/mcp/`):
- Profile-specific configs
- Tool usage patterns

**Project** (`{project}/docs/mcp/`):
- Project-specific integrations only

## Related

- Skill: `optimize-mcp-config` (implementation)
- Plugin: agents-context-system
- Companion: `/optimize-agents` (for AGENTS.md optimization)
- Integration: agents-documentation-suite (for MCP documentation)
