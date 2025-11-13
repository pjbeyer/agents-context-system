# Optimize AGENTS.md - Context Optimization

Analyze and optimize AGENTS.md files across hierarchy for token efficiency, redundancy elimination, and hierarchical correctness.

## Invocation

Use and follow the `optimize-agents-context` skill exactly as written.

## Usage

From any location in your project hierarchy:

```bash
/optimize-agents
```

The skill will:
1. Discover all AGENTS.md files in hierarchy
2. Measure current character/token usage
3. Detect redundancy across levels
4. Classify content (essential/detailed/redundant)
5. Provide optimization recommendations
6. Extract detailed content to docs/
7. Update files with references
8. Measure savings achieved

## Target Budgets

- Global AGENTS.md: 8-12k characters
- Profile AGENTS.md: 5-8k characters
- Project AGENTS.md: 4-6k characters
- Agent AGENTS.md: 2-6k characters

## Optimization Strategy

### Extract to /docs/
- Procedures → docs/workflows/
- Examples → docs/examples/
- Background → docs/architecture/
- Detailed lists → docs/reference/

### Reference, Don't Duplicate
- Children reference parents
- No duplication across hierarchy
- Cross-references clear and working

### Token Efficiency
- Prose → bullet lists
- Long descriptions → tables
- Verbose → concise phrases
- Keep only essential context

## Profile-Aware

Respects profile-specific standards:
- **pjbeyer**: Comprehensive but efficient
- **work**: Slim (3-5k target), security-focused
- **play**: Minimal overhead, flexible
- **home**: Practical, accessible

## Related

- Skill: `optimize-agents-context` (implementation)
- Plugin: agents-context-system
- Integration: agents-documentation-suite (for machine doc writing)
- Companion: `/optimize-mcp` (for MCP configuration)
