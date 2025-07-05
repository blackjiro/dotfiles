---
allowed-tools: Task(*), Read(*), Edit(*), MultiEdit(*), Write(*), Grep(*), Glob(*), TodoWrite(*), TodoRead(*)
description: "Claude Codeのサブタスクを使用してファイルの競合を回避しながら複数のリファクタリングタスクを並列実行"
---

# Parallel Refactoring Executor
Execute multiple refactoring tasks concurrently: $ARGUMENTS

## Instructions

1. **Parse and Analyze Refactoring Items**
   - Extract each refactoring item from the bullet list provided
   - For each item, analyze:
     - Which files will be affected
     - What specific changes need to be made
     - Dependencies between refactoring tasks
   - Create a detailed investigation report for each item

2. **Conflict Detection**
   - Map out all files that will be modified by each refactoring task
   - Identify any overlapping file modifications
   - Group non-conflicting tasks that can run in parallel
   - Create execution batches based on file dependencies

3. **Task Planning**
   - Use TodoWrite to create a structured task list
   - Organize tasks into parallel execution groups
   - Mark dependencies between tasks clearly
   - Set priority levels based on complexity and impact

4. **Investigation Phase**
   For each refactoring item:
   - Search for affected code using Grep/Glob
   - Read relevant files to understand current implementation
   - Document specific changes needed
   - Estimate complexity and risk level
   - Note any potential side effects

5. **Parallel Execution**
   - Launch multiple Task agents concurrently for non-overlapping refactorings
   - Each subtask should:
     ```
     - Focus on its specific refactoring item
     - Make all necessary code changes
     - Update related tests if applicable
     - Document changes made
     ```
   - Monitor progress through TodoRead

6. **Coordination and Reporting**
   - Track completion status of each subtask
   - Consolidate results from all parallel executions
   - Generate a summary report of:
     - Completed refactorings
     - Files modified
     - Any issues encountered
     - Suggested follow-up actions

## Error Handling

- If file conflicts are detected:
  - Reorganize tasks into sequential batches
  - Notify user of the conflict and proposed resolution
  
- If a subtask fails:
  - Continue with non-dependent tasks
  - Report the failure with context
  - Suggest manual intervention if needed

- If investigation reveals blockers:
  - Document the blocker clearly
  - Proceed with unblocked items
  - Provide recommendations for blocked items

## Usage Examples

Basic usage:
```
/workflows:parallel-refactor
- Replace all console.log with logger.debug
- Convert Promise chains to async/await in api/ directory
- Extract magic numbers to constants in utils/
- Rename getUser to fetchUserById across codebase
```

With specific scope:
```
/workflows:parallel-refactor
- Refactor authentication middleware to use JWT tokens
- Update all database queries to use parameterized statements
- Convert class components to functional components in components/legacy/
```

## Best Practices

1. **Clear Item Definition**
   - Each bullet point should be a self-contained refactoring task
   - Include scope/directory when relevant
   - Be specific about the transformation needed

2. **Batch Size Optimization**
   - Aim for 3-5 parallel tasks per batch
   - Consider system resources and complexity
   - Balance speed with stability

3. **Verification Steps**
   - Each subtask should verify its changes
   - Run relevant tests if available
   - Check for compilation/linting errors

## Output Format

The command will provide:
1. Initial investigation report for each item
2. Conflict analysis and execution plan
3. Real-time progress updates
4. Final summary with:
   - ✅ Completed refactorings
   - 📁 Modified files list
   - ⚠️ Any warnings or issues
   - 📋 Recommended next steps