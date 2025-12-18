# Skill Quality Checklist

Use this checklist before publishing your Skill to ensure it meets quality standards.

---

## YAML Frontmatter

- [ ] `name` field exists and is lowercase, kebab-case
- [ ] `name` field is ≤64 characters
- [ ] `name` contains only lowercase letters, numbers, hyphens (no spaces, caps, underscores)
- [ ] `name` does not contain XML tags
- [ ] `name` does not use reserved words (anthropic, claude)
- [ ] `description` field exists and is non-empty
- [ ] `description` is ≤1024 characters
- [ ] `description` does not contain XML tags
- [ ] `description` includes what the Skill does
- [ ] `description` includes when to use the Skill ("Use when...", "Use for...")
- [ ] `description` is in third person (not "I can...", "You can...")
- [ ] No other fields in frontmatter (keep it minimal)

---

## SKILL.md Structure

- [ ] File name is exactly `SKILL.md` (uppercase)
- [ ] SKILL.md is ≤300 lines total
- [ ] SKILL.md ≥50 lines (not too minimal)
- [ ] Main heading (`#`) appears once
- [ ] Quick Start section exists
- [ ] Quick Start is minimal (1-3 lines + 1 example)
- [ ] No time-sensitive information (e.g., "before August 2025")
- [ ] Examples include input/output pairs
- [ ] Examples show realistic use cases
- [ ] All code examples are correct and runnable
- [ ] External file references use relative paths (e.g., `[Link](ADVANCED.md)`)
- [ ] External file references use forward slashes, not backslashes
- [ ] All external file references are one level deep (not nested)
- [ ] No broken links to internal files
- [ ] No Windows-style paths (`scripts\file.py` → `scripts/file.py`)

---

## Content Quality

- [ ] Language is concise and clear
- [ ] No redundant explanations
- [ ] Assumes Claude is smart (doesn't over-explain basics)
- [ ] Consistent terminology throughout (not mixing "field", "box", "element")
- [ ] No vague language ("does stuff", "handles things")
- [ ] Technical terms are defined or linked
- [ ] Each section has a clear purpose
- [ ] Content is organized logically
- [ ] No duplicate information across files

---

## Examples & Patterns

- [ ] Quick Start example is minimal and correct
- [ ] Examples include realistic input/output
- [ ] At least 2-3 example scenarios present
- [ ] Code examples use language-specific syntax highlighting
- [ ] Code is properly indented
- [ ] Code examples can be copied and run
- [ ] Examples don't require external setup not mentioned in Skill

---

## Reference Files (if applicable)

- [ ] ADVANCED.md exists (if needed)
- [ ] ADVANCED.md is referenced from SKILL.md
- [ ] REFERENCE.md exists (if needed)
- [ ] REFERENCE.md is referenced from SKILL.md
- [ ] Reference files are one level deep from SKILL.md
- [ ] No deeply nested file references
- [ ] Each reference file focuses on one topic
- [ ] Reference files are properly named (uppercase: ADVANCED.md, REFERENCE.md)
- [ ] No duplicate content between SKILL.md and reference files

---

## Scripts (if applicable)

- [ ] Scripts are in `scripts/` directory
- [ ] Scripts have clear, descriptive names (not script1.py, helper.py)
- [ ] Scripts have error handling
- [ ] Scripts have documentation/docstrings
- [ ] Scripts are referenced correctly in SKILL.md
- [ ] Scripts can be executed independently
- [ ] Scripts produce clear output
- [ ] SKILL.md explains what each script does
- [ ] SKILL.md shows how to run each script

---

## File Organization

- [ ] Skill directory name matches `name` field in frontmatter
- [ ] Directory structure is clean and logical
- [ ] All files are necessary (no redundant files)
- [ ] Files are named descriptively (not doc1.md, file2.md)
- [ ] No extraneous files or directories
- [ ] Directory layout matches STRUCTURE.md patterns
- [ ] File naming is consistent (UPPERCASE for markdown)

---

## Discovery & Accessibility

- [ ] Description clearly states what Skill does
- [ ] Description clearly states when to use Skill
- [ ] Key terms appear in description that users might search for
- [ ] Skill name is intuitive (gerund form: processing-pdfs, not pdf-processor)
- [ ] First section (Quick Start) is immediately useful
- [ ] Someone unfamiliar with the domain can understand basics from SKILL.md alone

---

## Common Pitfalls to Avoid

- [ ] SKILL.md is not overly verbose (not a comprehensive manual)
- [ ] Description is not vague ("Helps with documents" → "Extracts text and tables from PDFs")
- [ ] Naming is not inconsistent (not mixing `my-skill`, `MySkill`, `my_skill`)
- [ ] References are not deeply nested (SKILL.md → file1 → file2 → actual content)
- [ ] Code examples are not copied from docs without testing
- [ ] No irrelevant content (every section should have a purpose)
- [ ] No placeholder text or TODOs left in published version
- [ ] No mention of specific dates or versions that will become outdated

---

## Testing & Validation

- [ ] Skill has been tested with actual use cases
- [ ] Skill activates correctly when description keywords match user request
- [ ] Quick Start example works when copied exactly
- [ ] All code examples produce expected output
- [ ] External files (ADVANCED.md, REFERENCE.md) load correctly when referenced
- [ ] Scripts execute without errors (with appropriate input)
- [ ] Skill is useful and solves the problem it claims to solve

---

## Final Review

Before Publishing:

1. **Self-Review**
   - [ ] Read SKILL.md from a fresh perspective
   - [ ] Imagine you're a new user - is it clear?
   - [ ] Are there any confusing sections?

2. **Peer Review** (if applicable)
   - [ ] Have someone else reviewed the Skill?
   - [ ] Did they understand it without your explanation?
   - [ ] Did they catch any issues?

3. **Technical Review**
   - [ ] All links work (internal and external)
   - [ ] All code runs without errors
   - [ ] All file paths are correct

4. **Completeness**
   - [ ] All necessary reference files exist
   - [ ] All scripts are functional
   - [ ] Documentation is complete

---

## Scoring

Count your checkmarks:

| Score | Status | Action |
|-------|--------|--------|
| 90-100% | ✓ Ready | Publish |
| 70-89% | ⚠ Almost | Fix flagged items and recheck |
| <70% | ✗ Needs work | Address major issues before publishing |

---

## Track Your Progress

Use this checklist version:

**Skill Name**: ________________

**Completion Date**: ________________

**Reviewer**: ________________

**Total Checks**: ________________

**Passed**: ________________

**Percentage**: ________________

**Published?**: ☐ Yes ☐ No ☐ Ready for Publishing

---

## Notes

Use this space to document any special considerations, known limitations, or future improvements:

```
[Your notes here]
```

---

## Example: Completed Checklist

**Skill Name**: processing-pdfs

**Key Passes**:
- ✓ Name: lowercase, kebab-case
- ✓ Description includes what and when
- ✓ SKILL.md is 240 lines
- ✓ Quick Start is minimal (2 lines + 1 example)
- ✓ 4 workflow examples with I/O
- ✓ ADVANCED.md and REFERENCE.md properly referenced
- ✓ 2 scripts (analyze.py, validate.py) with documentation
- ✓ Tested with 3 real PDFs

**Total Score**: 98% → **Ready to Publish**

---

**Remember**: A Skill is never truly "done" - you can always improve it based on feedback and usage. This checklist ensures minimum quality for publishing.
