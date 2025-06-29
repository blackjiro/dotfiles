# Claude Code Global Instructions

## Terminal Notifications

When work is completed or user interaction is required, send a notification using terminal-notifier:

```bash
terminal-notifier -title "Claude Code" -message "Task completed" -sound default
```

For user interaction required:
```bash
terminal-notifier -title "Claude Code" -message "User input needed" -sound default
```

Use these commands at appropriate completion points to keep the user informed when they may not be actively monitoring the terminal.

## Pull Request Creation

**MANDATORY**: Before creating any pull request, you MUST:

1. **ALWAYS** first check if `.github/pull_request_template.md` exists in the repository using the Read tool
2. If the template exists, you MUST read its contents and follow the exact format and structure
3. Include ALL required sections from the template in your PR description
4. Never create a PR without checking for and using the template if it exists

**CRITICAL**: This is a mandatory step that cannot be skipped. The template check and usage is required for every single PR creation request.

## Gemini Search

`gemini` is google gemini cli. **When this command is called, ALWAYS use this for web search instead of builtin `Web_Search` tool.**

When web search is needed, you MUST use `gemini --prompt` via Task Tool.

Run web search via Task Tool with `gemini --prompt 'WebSearch: <query>'`

Run

```bash
gemini --prompt "WebSearch: <query>"
```
