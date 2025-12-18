# Claude Code Global Instructions

## Language and Documentation

- Think in English but provide all answers and markdown document in Japanese unless otherwise specified.

## Pull Request Creation

**MANDATORY**: Before creating any pull request, you MUST:

1. **ALWAYS** first check if `.github/pull_request_template.md` exists in the repository using the Read tool
2. If the template exists, you MUST read its contents and follow the exact format and structure
3. Include ALL required sections from the template in your PR description
4. Never create a PR without checking for and using the template if it exists

**CRITICAL**: This is a mandatory step that cannot be skipped. The template check and usage is required for every single PR creation request.

## Git Commit Policy

**IMPORTANT**: Never create git commits unless explicitly instructed by the user. Only commit changes when the user specifically asks you to do so.

## Development Principles (Kent Beck's TDD & Tidy First)

**Core Philosophy**: Simplicity first, following Kent Beck's methodologies

### Implementation Guidelines:
1. **Check Existing Code First**: Review existing files before creating new ones
2. **Reuse and Extend**: Implement in existing files when possible
3. **DRY & Clean Code**: Remove duplication, dead code, maintain single responsibility
4. **Minimal Implementation**: Only what's needed now - no speculative features
5. **Destructive Simplicity**: Breaking changes acceptable for cleaner code
6. **No Code Comments**: Unless explicitly requested (exception: critical design decisions)

### TDD Cycle: Red → Green → Refactor
- Write failing test first → Minimal code to pass → Improve while keeping tests green
- Small iterations, test-first approach
- Test only through public interfaces, never private functions directly
- Focus on behavior/outcomes, not implementation details

### Tidy First Refactoring:
- Small, safe refactoring steps before new features
- Maintain cohesion - keep related functionality together

## External Modules and Tools

**When using external modules, libraries, or development tools**:

1. **Always use context7 MCP server** to retrieve up-to-date documentation and code examples
2. **Check library documentation first**: Before implementing code with external dependencies, consult context7 for current best practices and usage patterns
3. **Version-aware queries**: When available, specify the library version to get accurate documentation
4. **Verify compatibility**: Use context7 to confirm module compatibility and requirements before implementation
