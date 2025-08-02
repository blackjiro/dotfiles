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
gemini --model gemini-2.5-flash --prompt "WebSearch: <query> latest"
```

Or use time-specific queries:

```bash
gemini --model gemini-2.5-flash --prompt "WebSearch: <query> as of 2025 current status latest updates"
```

## Code Implementation Guidelines

When implementing code or planning implementation:

1. **Check Existing Code First**: Before creating new files, always review existing code to find files that handle the same domain or business logic
2. **Reuse and Extend**: Look for opportunities to implement new functionality within existing files rather than creating new ones
3. **DRY Principle**: When similar logic exists in util files or the same file, consolidate by extracting common functions to avoid duplication
4. **Maintain Cohesion**: Keep related functionality together to improve code organization and maintainability
5. **Minimal Implementation**: Write only the minimum code necessary to fulfill requirements - avoid adding unnecessary features, options, or complexity
6. **Prioritize Existing Functions**: Before creating new functions, always check if existing functions can be modified or refactored to handle new requirements
7. **No Speculative Features**: Do not implement functionality that might be useful in the future - only implement what is explicitly needed now
8. **Allow Destructive Changes for Simplicity**: When refactoring or reimplementing code, prioritize simplicity over preserving existing code. Breaking changes are acceptable if they result in cleaner, simpler implementations with no unnecessary code left behind

## Test-Driven Development (TDD) & Tidy First Principles

**Always follow TDD principles when developing code**:

1. **Red**: Write a failing test first that describes the desired behavior
2. **Green**: Write the minimal code necessary to make the test pass
3. **Refactor**: Improve the code while keeping tests passing
4. **Test First**: Never write implementation code before writing tests
5. **Small Steps**: Work in small iterations, one test at a time

**Follow Kent Beck's Tidy First refactoring approach**:

1. **Simplicity First**: Always choose the simplest implementation that works
2. **Avoid Duplication**: Extract common functionality into reusable functions to eliminate similar code patterns
3. **Small Refactoring Steps**: Make tiny, safe improvements before adding new features
4. **Clean Code Incrementally**: Tidy up existing code structure before implementing new functionality
5. **Minimize Complexity**: Avoid over-engineering and unnecessary abstractions
6. **Function Clarity**: Each function should have a single, clear responsibility
7. **Remove Dead Code**: Eliminate unused functions, variables, and imports
8. **Consistent Naming**: Use clear, descriptive names that express intent

## External Modules and Tools

**When using external modules, libraries, or development tools**:

1. **Always use context7 MCP server** to retrieve up-to-date documentation and code examples
2. **Check library documentation first**: Before implementing code with external dependencies, consult context7 for current best practices and usage patterns
3. **Version-aware queries**: When available, specify the library version to get accurate documentation
4. **Verify compatibility**: Use context7 to confirm module compatibility and requirements before implementation


