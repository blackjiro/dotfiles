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

When creating pull requests, check for and use the format from `.github/pull_request_template.md` if it exists in the repository. Follow the template structure and requirements when drafting PR descriptions.