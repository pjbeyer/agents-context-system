# Add Task - Hierarchy-Aware Task Management

Add tasks to the appropriate hierarchy level with proper context awareness and integration with external systems.

## Invocation

Use and follow the `add-task` skill exactly as written.

## Usage

From any location in your project hierarchy:

```bash
/add-task
```

The skill will:
1. Detect current hierarchy level
2. Determine appropriate task file location
3. Create task with proper format
4. Add to hierarchy-aware task management
5. Optionally integrate with Jira/OmniFocus

## Task Hierarchy

### Global Tasks
**Location**: `~/Projects/docs/tasks/global.md`
**Scope**: Cross-profile tasks, environment setup

### Profile Tasks
**Location**: `{profilePath}/docs/tasks/profile.md`
**Scope**: Profile-specific tasks, standards

### Project Tasks
**Location**: `{projectPath}/docs/tasks/project.md`
**Scope**: Project features, fixes, improvements

### Agent Tasks
**Location**: `{agentPath}/docs/tasks/agent.md`
**Scope**: Agent-specific improvements

## Task Format

```markdown
## [Date] - [Task Title]

**Priority**: [Critical|High|Medium|Low]
**Status**: [Pending|In Progress|Completed|Blocked]
**Context**: [Brief context]

**Task**:
[Description]

**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2
```

## External Integration

### Work Profile
Tasks in work profile can optionally create Jira tickets with automatic linking.

### Personal
Tasks can optionally sync to OmniFocus for personal task management.

## Related

- Skill: `add-task`, `manage-tasks` (implementation)
- Plugin: agents-context-system
- Companion: Task management workflows
- Integration: Jira (work), OmniFocus (personal)
