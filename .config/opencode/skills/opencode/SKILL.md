---
name: opencode
description: OpenCode customization, configuration, and behavioral rules
license: MIT
compatibility: opencode
---

## What I do
- Explain OpenCode configuration structure and options
- Help customize agent behavior via config files
- Guide permission setup for operations
- Explain agent types and their capabilities

## Config File Structure
Location: `~/.config/opencode/opencode.json`

### Key Configuration Options

**Theme:** `"system" | "dark" | "light"`

**Default Agent:** Primary agent to use (e.g., `"plan"`, `"build"`)

**Permissions:** Fine-grained access control for operations:
- `external_directory`: Control access to directories outside the project
- `edit`: Allow/deny/ask for file modifications
- `read`: Control file reading (supports patterns like `"*.env"`)
- `glob`/`grep`: Search operations
- `bash`: Shell command execution (supports patterns for auto-approval)
- `question`: Allow agent to ask questions
- `plan_enter`/`plan_exit`: Control planning mode
- `skill`: Control which skills agents can access

**Permission Actions:**
- `"allow"`: Auto-approve
- `"ask"`: Prompt user
- `"deny"`: Block operation

**Pattern Matching:** Use glob patterns for granular control:
```json
{
  "bash": {
    "git status *": "allow",
    "git commit *": "deny",
    "go mod tidy": "allow"
  }
}
```

## Agent Types

**Primary Agents:**
- `build`: Full access, can ask questions, use planning
- `plan`: Planning mode with limited edit permissions
- `summary`: Read-only, generates summaries
- `compaction`: Read-only compaction tasks
- `title`: Read-only title generation

**Subagents:**
- `general`: Multi-step tasks, no todo/question access
- `explore`: Codebase exploration, read-only operations

## Global Agent Instructions
Location: `~/.config/opencode/AGENTS.md`

Use this file for:
- Global behavioral rules (e.g., "never run git commit")
- Communication preferences (e.g., "be concise")
- Persistent context across all sessions

## Per-Project Instructions
Location: `<project>/.opencode/AGENTS.md` or `<project>/AGENTS.md`

Project-specific context:
- Tech stack
- Build commands
- Project structure
- Team conventions

## Skills
Location: `~/.config/opencode/skills/<name>/SKILL.md`

Skills provide reusable knowledge modules. Each `SKILL.md` requires YAML frontmatter:
```yaml
---
name: skill-name  # lowercase alphanumeric with hyphens
description: What this skill does
license: MIT  # optional
compatibility: opencode  # optional
---
```

## CLI Commands
- `opencode [project]`: Start TUI in project directory
- `opencode run [message]`: Execute single command
- `opencode agent list`: Show available agents
- `opencode models [provider]`: List available models
- `opencode --agent <name>`: Start with specific agent
- `opencode -m <provider/model>`: Use specific model

## Permission Philosophy
- Default to `"ask"` for destructive operations
- Auto-allow safe read operations (`ls`, `git status`, `git diff`)
- Auto-allow specific build commands (`go mod tidy`, `npm install`)
- Always block git write operations (`git commit`, `git push`) unless explicitly needed

## Custom Agent Creation
Location: `~/.config/opencode/agents/<name>.md`

Custom agents extend OpenCode with specialized behaviors and permission models.

### Agent File Structure

Each agent file contains YAML frontmatter followed by a Markdown system prompt:

```yaml
---
description: Brief description of agent purpose
mode: primary  # or "subagent"
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1  # 0.0-1.0 (lower = consistent, higher = creative)
tools:
  read: true
  write: false
  edit: false
  glob: true
  grep: true
  bash: true
  webfetch: true
  question: true
permission:
  write: deny
  edit: deny
  bash: ask
---

Your system prompt and instructions go here...
```

### Agent Modes

**Primary Agents** (`mode: primary`):
- Can be set as default agent
- Invoked with `opencode --agent <name>`
- Full-featured agents for interactive use
- Examples: `build`, `plan`, `summary`

**Subagents** (`mode: subagent`):
- Invoked via Task tool: `Task(subagent_type="<name>", prompt="...")`
- Specialized for specific tasks
- Typically deny `question` and `todowrite` permissions
- Examples: `general`, `explore`

### Frontmatter Fields

**Required:**
- `description`: Short description shown in `opencode agent list`
- `mode`: `primary` or `subagent`

**Optional:**
- `model`: Override default model (e.g., `anthropic/claude-sonnet-4-20250514`)
- `temperature`: Control creativity (0.0 = deterministic, 1.0 = very creative)
- `tools`: Boolean flags for tool availability
- `permission`: Override specific permissions with `allow`, `ask`, or `deny`

### Tools Configuration

Available tool flags:
- `read`: Read files from filesystem
- `write`: Create new files
- `edit`: Modify existing files
- `glob`: Search for files by pattern
- `grep`: Search file contents
- `bash`: Execute shell commands
- `webfetch`: Fetch web content
- `question`: Ask user questions
- `todoread`/`todowrite`: Todo list management
- `plan_enter`/`plan_exit`: Planning mode transitions

### Permission Overrides

Agent-level permissions support both simple values and granular pattern syntax (same as opencode.json):

```yaml
# Simple value — applies to all inputs
permission:
  write: deny
  webfetch: allow

# Granular patterns — last matching rule wins
permission:
  bash:
    "*": ask
    "git diff": allow
    "git log*": allow
    "grep *": allow
  external_directory:
    "~/.config/opencode/**": allow
  edit: deny
```

Both `~` and `$HOME` are expanded in patterns. The `tools` config (deprecated) uses booleans; prefer `permission` for new configs.

### Agent Design Patterns

**Read-Only Agent** (code review, analysis):
```yaml
tools:
  read: true
  write: false
  edit: false
permission:
  write: deny
  edit: deny
```

**Theoretical/No-Filesystem Agent** (architecture advice):
```yaml
tools:
  read: false
  glob: false
  grep: false
  bash: false
  webfetch: true
  question: true
permission:
  read: deny
  glob: deny
  grep: deny
  bash: ask  # Allow with permission for help/man pages
```

**Interactive Planning Agent**:
```yaml
tools:
  question: true
  plan_enter: true
  plan_exit: true
permission:
  write: deny
  edit: ask
```

### Temperature Tuning

- **0.1-0.3**: Focused, consistent, deterministic (code review, linting)
- **0.4-0.5**: Balanced (general coding tasks)
- **0.6-0.7**: Creative, exploratory (brainstorming, architecture design)
- **0.8-1.0**: Very creative (rarely used, can be unpredictable)

### Invocation Methods

**Start with specific agent:**
```bash
opencode --agent <name>
```

**Set as default** in `~/.config/opencode/opencode.json`:
```json
{
  "default_agent": "theorize"
}
```

**Invoke as subagent** from another agent:
```
Task(subagent_type="theorize", prompt="How should I structure this?")
```

### Validation

Check agent configuration:
```bash
opencode agent list
```

If there's a validation error, it will show:
```
Error: Configuration is invalid at /path/to/agent.md
↳ Invalid input permission
```

Common issues:
- Invalid mode (must be `primary` or `subagent`)
- Invalid permission values (must be `allow`, `ask`, or `deny`)

### Example: Custom Agent

```yaml
---
description: Reviews Go microservice code for quality and best practices
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
tools:
  read: true
  write: false
  edit: false
  bash: true
permission:
  edit: deny
  write: deny
---

You are an expert Go code reviewer...
[System prompt continues]
```

## Best Practices
1. Use `external_directory` to whitelist project directories
2. Pattern-match dangerous commands to `"deny"`
3. Use AGENTS.md for persistent preferences
4. Keep permissions minimal - prefer `"ask"` over `"allow"`
5. Use project-specific AGENTS.md for tech stack details
6. Custom agents: Start with restrictive permissions, expand as needed
7. Use subagents for specialized tasks, primary agents for interactive work
8. Test agent configs with `opencode agent list` before use
```
