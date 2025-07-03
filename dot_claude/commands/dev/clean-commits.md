---
allowed-tools: ["Bash", "Read", "TodoWrite", "TodoRead"]
description: "PRのコミット履歴をクリーンアップし、論理的なコミットに整理"
---

# Clean Commits

The PR is ready for review. Please reorganize the commit history on this branch by:

1. Analyzing all changes made since branching from the base branch
2. Grouping related changes into logical, atomic commits
3. Writing clear, descriptive commit messages that explain the "why" behind each change
4. Using interactive rebase to clean up the history
5. Ensuring each commit passes tests independently (if applicable)

Guidelines:
- Each commit should represent one logical change
- Avoid mixing refactoring with feature changes in the same commit
- If the changes are minimal, don't force unnecessary splits
- Preserve the original functionality while improving commit organization
- Follow the repository's commit message conventions if they exist