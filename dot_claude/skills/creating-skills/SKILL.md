---
name: creating-skills
description: Create and improve Agent Skills with structured planning and best practices. Use when designing new Skills, enhancing existing Skills, refactoring existing Skills, or ensuring Skill quality in Claude Code.
---

# Creating Agent Skills

## Quick Start: 5-Step Workflow

Creating an Agent Skill involves planning, designing, and packaging. Follow this workflow:

1. **Determine Purpose & Scope** - What problem does your Skill solve?
2. **Design Using PLANNING.md** - Clarify use cases and structure
3. **Create SKILL.md from Template** - Use SKILL_TEMPLATE.md as your starting point
4. **Review with Checklist** - Validate against CHECKLIST.md before finalizing
5. **Integrate** - Add to settings.json and test

## Skill Planning

Before writing SKILL.md, use [PLANNING.md](PLANNING.md) to clarify:
- **Name**: Gerund form, kebab-case (e.g., `processing-pdfs`, `analyzing-spreadsheets`)
- **Description**: What it does + when to use it (max 1024 chars)
- **Scope**: What's included / excluded
- **Target Users**: Who will use this Skill?
- **Use Cases**: 2-3 concrete scenarios

Planning prevents unclear Skill designs and ensures the final SKILL.md is discoverable.

## SKILL.md Structure

Your Skill needs a `SKILL.md` file with this structure:

```yaml
---
name: your-skill-name
description: What this Skill does and when to use it
---

# Your Skill Name

## Quick Start
[Minimal example or 2-3 line overview]

## Key Concepts
[What Claude needs to know to use this Skill]

## Workflows
[Step-by-step instructions for common tasks]

## Examples
[Real input/output pairs]

## Reference
[Link to detailed files: ADVANCED.md, API.md, etc]
```

**Critical Guidelines**:
- Keep SKILL.md under 300 lines (progressive disclosure)
- Description must state both "what" and "when to use"
- Naming must use lowercase letters, numbers, hyphens (no spaces, caps, or special chars)
- Examples should include input/output pairs

For detailed structure guidance, see [STRUCTURE.md](STRUCTURE.md).

## Best Practices Summary

**Conciseness**: SKILL.md body should be ~200-300 lines. Put detailed content in separate files (ADVANCED.md, REFERENCE.md) and reference them from SKILL.md.

**Naming**: Use gerund form: `processing-pdfs` not `pdf-processor`. Names are lowercase only.

**Description**: Include both capability and discovery keywords.
- ✓ "Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."
- ✗ "Processes documents"

**Progressive Disclosure**: Structure content in levels:
- Level 1: Metadata (YAML frontmatter) - always loaded
- Level 2: SKILL.md body - loaded when Skill triggers
- Level 3: Reference files - loaded only when needed

**Testing**: Create evaluations *before* writing extensive docs. Test your Skill with actual use cases.

For comprehensive best practices, see [BEST_PRACTICES.md](BEST_PRACTICES.md).

## Examples & Patterns

### Pattern 1: Reference-Heavy Skill
When you have extensive content, structure it like this:

```
your-skill/
├── SKILL.md (200-250 lines)
├── REFERENCE.md (API, detailed patterns)
├── ADVANCED.md (complex scenarios)
└── EXAMPLES.md (input/output samples)
```

SKILL.md points to these files; Claude loads them as needed.

### Pattern 2: Simple Skill
For straightforward Skills, everything can fit in SKILL.md:

```
simple-skill/
└── SKILL.md (100-150 lines)
```

See [EXAMPLES.md](EXAMPLES.md) for real implementations (RsDT, etc).

## Validation Checklist

Before finalizing, verify:

- [ ] Name: lowercase, hyphens, gerund form
- [ ] Description: includes "what" and "when to use" (≤1024 chars)
- [ ] SKILL.md ≤300 lines
- [ ] Frontmatter has `name` and `description` only (no other fields)
- [ ] Quick Start section present and minimal
- [ ] Examples include concrete input/output
- [ ] All file references are one level deep (no nested references)
- [ ] No XML tags in name or description
- [ ] Tested with actual use case

See [CHECKLIST.md](CHECKLIST.md) for the full quality rubric.

## Common Mistakes

**Too verbose**: SKILL.md tries to include everything. Split into ADVANCED.md, REFERENCE.md.

**Unclear description**: Doesn't say when Claude should use this Skill. Add keywords: "use when", "use for", etc.

**Inconsistent naming**: Mix of `my-skill`, `MySkill`, `my_skill`. Stick to gerund form, lowercase, hyphens.

**Deeply nested references**: SKILL.md → ADVANCED.md → DETAILS.md. Keep references one level deep from SKILL.md.

**No examples**: Say "extract text from PDFs" but show no code. Always include concrete input/output pairs.

## Getting Started

1. Read [PLANNING.md](PLANNING.md) to define your Skill
2. Use [SKILL_TEMPLATE.md](SKILL_TEMPLATE.md) as your starting point
3. Fill in the template section by section
4. Review against [CHECKLIST.md](CHECKLIST.md)
5. For reference, see [EXAMPLES.md](EXAMPLES.md)

## Additional Resources

- **API/Library Docs**: Use context7 MCP to fetch latest documentation
- **Web Search**: Use WebSearch to find current best practices and patterns
- **Official Docs**: See https://platform.claude.com/docs/en/agents-and-tools/agent-skills/ for complete Agent Skills documentation

---

**Key Principle**: Progressive disclosure keeps your Skill efficient. SKILL.md is the entry point; detailed content lives in reference files accessed only when needed.
