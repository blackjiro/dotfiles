---
allowed-tools: Read, Grep, LS
description: "Check implementation status of task checklists in markdown files"
---

# Check Task Implementation Status

Check the implementation status of tasks in a markdown file by analyzing the codebase: $ARGUMENTS

## Instructions

1. **Parse the target file**
   - Read the specified markdown file (default: PLAN.md if no file specified)
   - Extract all checklist items (lines starting with `- [ ]` or `- [x]`)
   - Identify unchecked tasks that need verification

2. **Analyze implementation status**
   - For each unchecked task, search the codebase for related implementations
   - Look for file names, function names, or code patterns mentioned in the task
   - Check if the described functionality exists in the code

3. **Update task status**
   - Mark tasks as complete (`- [x]`) if implementation is found
   - Keep tasks unchecked (`- [ ]`) if implementation is missing or incomplete
   - Add brief notes about what was found or what's missing

4. **Generate summary report**
   - Show the updated checklist with current status
   - Provide a summary of completed vs pending tasks
   - List any tasks that couldn't be automatically verified

## Usage Examples

Check default PLAN.md file:
```
/utils:check-tasks
```

Check specific markdown file:
```
/utils:check-tasks TODO.md
```

Check with detailed analysis:
```
/utils:check-tasks "ROADMAP.md with detailed implementation notes"
```

## Error Handling

- If the specified file doesn't exist, list available markdown files with checklists
- If no checklists are found, report this clearly
- For ambiguous task descriptions, note them for manual review
