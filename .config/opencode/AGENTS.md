## Global Agent Instructions

### Project Context

At the start of every session, agents MUST read the README.md file from the current project directory to understand the project's:
- Setup and prerequisites
- Build and deployment procedures
- Testing requirements and conventions
- Development workflows and tools
- Project-specific context and conventions

### Error Handling

If README.md does not exist in the current project directory, proceed without it.

### Context Usage

Agents should reference README.md when:
- Making decisions about project structure
- Determining appropriate build, test, and deployment commands
- Understanding project conventions and best practices
- Providing guidance on development workflows
- Understanding dependencies and architecture

### CLANKER Comments

CLANKER comments are inline feedback left by the user in source code. They follow the format `CLANKER: <message>`.

When asked to "check the clanker comments", agents MUST:
1. Search the codebase for `CLANKER:` using grep with surrounding context (e.g., 3 lines above and below)
2. Read and address each comment found
3. After resolving a CLANKER comment, remove it from the code
