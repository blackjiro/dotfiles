# Claude Code Global Instructions

## Pull Request Creation

**MANDATORY**: Before creating any pull request, you MUST:

1. **ALWAYS** first check if `.github/pull_request_template.md` exists in the repository using the Read tool
2. If the template exists, you MUST read its contents and follow the exact format and structure
3. Include ALL required sections from the template in your PR description
4. Never create a PR without checking for and using the template if it exists

**CRITICAL**: This is a mandatory step that cannot be skipped. The template check and usage is required for every single PR creation request.

## Gemini Search

`gemini` is google gemini cli. **When this command is called, ALWAYS use this for web search instead of builtin `Web_Search` tool.**

When web search is needed, you MUST use `gemini --model gemini-2.5-flash --prompt` via Task Tool.

**IMPORTANT**: Always ensure you get the most current and up-to-date information by explicitly requesting recent data in your search queries.

Run web search via Task Tool with enhanced prompts for current data:

```bash
gemini --model gemini-2.5-flash --prompt "WebSearch: <query>"
```

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

## Post-Implementation Verification

**MANDATORY - DO NOT SKIP**: After completing a planned feature or set of related changes, you MUST perform these verification steps:

### ⚠️ CRITICAL REQUIREMENT ⚠️

**This is NOT optional. These steps MUST be executed when the planned implementation is complete:**

1. **Refactoring Review (REQUIRED)**:
   - **ACTION**: Invoke the `tidy-first-refactoring-expert` agent
   - **PURPOSE**: Review the complete implementation for potential improvements and apply suggested refactoring
   - **WHEN**: After finishing a complete feature, bug fix, or set of related changes
   - **SCOPE**: Review all files modified during the implementation task

2. **Code Quality Check (REQUIRED when applicable)**:
   - **ACTION**: If linter/formatter configuration exists, invoke the `code-formatter-linter` agent
   - **PURPOSE**: Ensure all formatting and linting rules pass
   - **WHEN**: After completing the planned changes and any refactoring
   - **CHECK FIRST**: Look for config files like `.eslintrc`, `ruff.toml`, `prettier.config.js`, etc.

### ⛔ IMPORTANT: A task is NOT complete until these verification steps are done ⛔

**EXECUTION TIMING**: Run these verification steps:

- After completing a full feature implementation
- After finishing a bug fix
- After completing a set of related changes
- Before reporting task completion to the user
- NOT after every individual file edit or small code change

## External Modules and Tools

**When using external modules, libraries, or development tools**:

1. **Always use context7 MCP server** to retrieve up-to-date documentation and code examples
2. **Check library documentation first**: Before implementing code with external dependencies, consult context7 for current best practices and usage patterns
3. **Version-aware queries**: When available, specify the library version to get accurate documentation
4. **Verify compatibility**: Use context7 to confirm module compatibility and requirements before implementation
