---
allowed-tools: Edit, ReadFile, Bash(mkdir:*)
description: "Generate custom slash commands for various development workflows based on requirements"
---

# Generate Custom Slash Command

Create a new slash command based on: $ARGUMENTS

## Phase 1: Requirements Analysis

1. **Parse the command specification**
   - Extract the command purpose from $ARGUMENTS
   - Identify the target workflow or problem to solve
   - Determine required tools and permissions
   - Define success criteria and output format

2. **Categorize the command type**
   - Analysis/Review commands (code-review, security-audit)
   - Generation commands (create-component, scaffold-api)
   - Workflow commands (deploy, test-suite)
   - Utility commands (format-code, clean-cache)

## Phase 2: Command Structure Generation

1. **Create the file structure**
   ```bash
   # Determine appropriate subdirectory based on command type
   # Examples: git/, testing/, deployment/, utilities/, workflows/
   mkdir -p .claude/commands/[category]
   ```

2. **Generate the command file**
   Create `.claude/commands/[category]/[command-name].md` with appropriate structure:

   ```markdown
   ---
   allowed-tools: [Select appropriate tools based on command type]
   description: "[Generated description based on requirements]"
   ---

   # [Command Title]
   [Purpose statement based on requirements]

   ## Instructions
   [Step-by-step workflow tailored to the specific use case]

   ## Error Handling
   [Common failure scenarios and recovery steps]

   ## Usage Examples
   [Concrete examples of command invocation]
   ```

## Phase 3: Command Content Generation

Based on the command type, include appropriate sections:

### For Analysis Commands:
- Repository structure analysis steps
- Code quality evaluation criteria
- Security assessment guidelines
- Performance analysis metrics
- Reporting format specifications

### For Generation Commands:
- Template selection logic
- Variable substitution patterns
- File creation workflows
- Boilerplate customization
- Post-generation validation

### For Workflow Commands:
- Pre-flight checks and validations
- Sequential task execution
- Rollback procedures
- Success verification steps
- Integration points

### For Utility Commands:
- Input validation
- Core functionality implementation
- Output formatting
- Cleanup procedures

## Phase 4: Optimization and Testing

1. **Optimize the generated command**
   - Ensure clarity and conciseness
   - Add appropriate context loading with !`commands` and @files
   - Include relevant tool permissions
   - Implement efficient workflows

2. **Add command metadata**
   - Usage documentation
   - Parameter descriptions
   - Example invocations
   - Related commands

3. **Validate the command**
   - Check syntax and structure
   - Verify tool permissions
   - Test parameter substitution
   - Ensure error handling paths

## Template Patterns

Generate commands using these proven patterns:

### Basic Command Template:
```markdown
---
allowed-tools: [Tools]
description: "[Description]"
---

# [Title]
[Purpose]: $ARGUMENTS

## Instructions
1. **Analysis Phase**
   - Understand requirements
   - Validate prerequisites
   
2. **Implementation Phase**
   - Execute main workflow
   - Handle edge cases
   
3. **Verification Phase**
   - Test results
   - Generate output
```

### Advanced Workflow Template:
```markdown
---
allowed-tools: [Multiple tools]
description: "[Complex workflow description]"
---

# [Title]
[Purpose]: $ARGUMENTS

## Current Context
- Status: !`[status command]`
- Config: @[config file]

## Multi-Phase Workflow
1. **Pre-flight Checks**
2. **Core Implementation**
3. **Quality Assurance**
4. **Completion and Cleanup**

## Error Recovery
[Specific error handling strategies]
```

## Usage Examples

Create basic utility command:
```
/generate-command "format all TypeScript files in project"
```

Create complex workflow command:
```
/generate-command "complete feature development with testing, documentation, and PR creation"
```

Create analysis command:
```
/generate-command "perform security audit of API endpoints"
```

## Output

The command will:
1. Create the appropriate directory structure
2. Generate a complete, functional slash command file
3. Include all necessary metadata and structure
4. Provide usage examples and documentation
5. Validate the generated command structure

The generated command will be immediately usable with `/[category]:[command-name]` syntax.
