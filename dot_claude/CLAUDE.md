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
gemini --model gemini-2.5-flash --prompt "WebSearch: <query> latest 2024 2025 current recent updated"
```

Or use time-specific queries:

```bash
gemini --model gemini-2.5-flash --prompt "WebSearch: <query> as of 2025 current status latest updates"
```

Always include temporal keywords like "latest", "current", "2024", "2025", "recent", "updated" to ensure fresh results.
