# Agent Skills Best Practices

This is a summary of best practices for creating effective Agent Skills for Claude Code. For comprehensive details, see the [official Agent Skills documentation](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices).

---

## Core Principles

### 1. Conciseness is Key

**The Problem**: Every token in your SKILL.md competes with conversation history and other Skills' metadata in the context window.

**The Rule**:
- SKILL.md body: 150-300 lines maximum (aim for ~250 as a sweet spot)
- Move detailed content to separate reference files
- Claude loads only what it needs (progressive disclosure)

**Example**:

✓ **Concise** (~50 tokens):
```markdown
## Extract PDF Text

Use pdfplumber:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
```

✗ **Too Verbose** (~200+ tokens):
```markdown
## Extract PDF Text

PDFs are a common file format. To extract text, you need a library.
There are many options, but we recommend pdfplumber because it's
easy to use and handles most cases well. First install it using pip.
Then you can write code like this...
```

**Principle**: Assume Claude already knows what PDFs are, how libraries work, and how to read documentation.

---

### 2. Description: Critical for Discovery

**What**: The `description` field in SKILL.md frontmatter.

**Why**: Claude uses it to decide whether to load your Skill when the user makes a request. If your description is vague, Claude won't activate your Skill even when it's relevant.

**The Rule**:
- Include both **what** the Skill does and **when** to use it
- Use keywords that match user language
- Max 1024 characters
- Write in **third person** (not "I can..." or "You can...")

**Good Examples**:

✓ "Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."

✓ "Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files."

✗ "Helps with documents" (too vague)

✗ "I can process your PDFs" (wrong person, no "when to use")

---

### 3. Progressive Disclosure: Levels of Loading

**Level 1 (Always loaded)**:
- Metadata from YAML frontmatter: name, description
- Token cost: ~100 tokens per Skill

**Level 2 (Loaded when triggered)**:
- SKILL.md body with instructions
- Token cost: ~5k tokens max

**Level 3 (Loaded as needed)**:
- Reference files (ADVANCED.md, REFERENCE.md, EXAMPLES.md)
- Code execution (scripts run without loading into context)
- Token cost: Effectively unlimited (files loaded on-demand)

**Pattern**:
```
your-skill/
├── SKILL.md (overview, quick start, references to detail files)
├── ADVANCED.md (detailed patterns, advanced techniques)
├── REFERENCE.md (API reference, complete options)
└── scripts/
    └── validate.py (executed, not loaded into context)
```

---

## Practical Guidelines

### 4. Naming Conventions

**Use gerund form** (verb-ing):
- ✓ `processing-pdfs` (what it does)
- ✓ `analyzing-spreadsheets`
- ✓ `writing-documentation`

**Other acceptable forms**:
- Noun phrase: `pdf-processing`, `spreadsheet-analysis`
- Action-oriented: `process-pdfs`, `analyze-spreadsheets`

**Avoid**:
- Vague: `helper`, `utils`, `tools`
- Generic: `documents`, `data`, `files`
- Reserved words: `anthropic-helper`, `claude-tools`

**Technical constraints**:
- Lowercase letters, numbers, hyphens only
- Max 64 characters
- No XML tags
- No reserved words ("anthropic", "claude")

---

### 5. Frontmatter Fields

Your SKILL.md must have exactly these fields:

```yaml
---
name: your-skill-name
description: What this Skill does and when to use it (max 1024 chars)
---
```

**Rules**:
- `name`: lowercase, hyphens, ≤64 chars
- `description`: non-empty, ≤1024 chars, no XML tags
- No other fields (keep it simple)

---

### 6. Structure Pattern: SKILL.md Body

A good SKILL.md follows this structure:

```markdown
# Skill Name

## Quick Start
[1-2 line overview or minimal example]

## Key Concepts
[What Claude needs to understand]

## Common Workflows
[Step-by-step instructions]

## Examples
[Concrete input/output pairs]

## Advanced Topics / Reference
[Links to ADVANCED.md, REFERENCE.md]
```

---

### 7. Examples: Include Input/Output Pairs

**Bad**: Describe the Skill in prose without showing code

**Good**: Show concrete before/after:

```markdown
## Example: Extract Table from PDF

Input: A PDF file containing a pricing table
Output: Extracted data in JSON format

```json
{
  "table": [
    {"product": "Widget", "price": "$10"},
    {"product": "Gadget", "price": "$20"}
  ]
}
```
```

---

### 8. Avoid Common Patterns

### Anti-pattern 1: Windows-style paths
✗ `scripts\helper.py`
✓ `scripts/helper.py`

### Anti-pattern 2: Deeply nested references
✗ SKILL.md → ADVANCED.md → DETAILS.md → actual info

✓ SKILL.md → REFERENCE.md, ADVANCED.md (one level deep)

### Anti-pattern 3: Too many options
✗ "You can use pypdf, pdfplumber, PyMuPDF, pdf2image, or..."

✓ "Use pdfplumber for text extraction. For scanned PDFs with OCR, use pdf2image + pytesseract."

### Anti-pattern 4: Offering choices without context
✗ Just listing 5 libraries without guidance

✓ Recommend one default with clear alternatives for specific use cases

---

## Design Decisions

### 9. Degree of Freedom

Match specificity to task fragility:

**High Freedom** (text instructions):
- Multiple valid approaches exist
- Decisions depend on context
- Example: "Code review process" (depends on codebase)

**Medium Freedom** (pseudocode + parameters):
- Preferred pattern exists but variations acceptable
- Configuration affects behavior

**Low Freedom** (specific scripts):
- Operations are fragile
- Specific sequence required
- Example: "Database migration" (must run exact steps)

---

### 10. Testing & Evaluation

**Evaluation-Driven Development**:
1. Create 3+ evaluation scenarios **before** writing the Skill
2. Test your Skill with these scenarios
3. Iterate based on results
4. Only then publish

**Example Evaluation**:
```json
{
  "skills": ["processing-pdfs"],
  "query": "Extract all text from this PDF and save it to output.txt",
  "files": ["test.pdf"],
  "expected_behavior": [
    "Read PDF successfully",
    "Extract all pages",
    "Save to output.txt in readable format"
  ]
}
```

---

### 11. Iterative Development

**Best approach**:

1. **Work with Claude A** (expert assistant)
   - Complete your task manually with Claude
   - Document context you repeatedly provide

2. **Create the Skill**
   - Ask Claude A: "Create a Skill for this pattern"
   - Claude understands Skill format natively

3. **Review for conciseness**
   - Remove unnecessary explanations
   - Claude might over-explain; prune it

4. **Test with Claude B** (fresh instance using the Skill)
   - Use it on real scenarios
   - Observe where it struggles

5. **Refine**
   - Return insights to Claude A
   - Update SKILL.md based on observations
   - Repeat

---

## Patterns by Skill Type

### Reference-Heavy Skills

For Skills with extensive content (BigQuery schemas, API docs, etc):

```
skill-name/
├── SKILL.md (overview + navigation)
└── reference/
    ├── finance.md
    ├── sales.md
    ├── product.md
```

SKILL.md stays lean, pointing users to relevant reference files.

### Simple Skills

For straightforward Skill (20-30 lines of code):

```
skill-name/
└── SKILL.md (all in one)
```

Everything fits in SKILL.md.

### Code-Heavy Skills

For Skills that execute scripts (form filling, data processing):

```
skill-name/
├── SKILL.md (instructions, links to scripts)
├── REFERENCE.md (detailed patterns)
└── scripts/
    ├── process.py
    ├── validate.py
    └── helpers.py
```

Scripts are executed, not loaded into context (efficient).

---

## Dos and Don'ts

### ✓ DO:
- Keep SKILL.md under 300 lines
- Write descriptions that state "what" and "when"
- Use gerund form for names
- Provide examples with input/output
- Split content across files using progressive disclosure
- Test before publishing
- Use consistent terminology

### ✗ DON'T:
- Write SKILL.md as a comprehensive manual (split into files)
- Use Windows paths
- Offer excessive options without guidance
- Write descriptions in first person
- Assume time-sensitive information won't change
- Create deeply nested file references
- Skip examples

---

## Checklist Before Publishing

- [ ] Name: lowercase, hyphens, gerund form, ≤64 chars
- [ ] Description: includes "what" and "when", ≤1024 chars, third person
- [ ] SKILL.md ≤300 lines
- [ ] Quick Start section exists and is minimal
- [ ] Examples include input/output pairs
- [ ] File references are one level deep
- [ ] No XML tags in name/description
- [ ] No time-sensitive information
- [ ] Tested with actual use cases (evaluation-driven)
- [ ] Concise language (assumes Claude is smart)

---

## Resources

- [Official Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Official Best Practices Guide](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Agent Skills Cookbook](https://github.com/anthropics/claude-cookbooks/tree/main/skills)

---

**Key Takeaway**: Progressive disclosure keeps context efficient. SKILL.md is your elevator pitch; detailed content lives in reference files accessed only when needed. Write concisely, assume Claude is smart, and test before publishing.
