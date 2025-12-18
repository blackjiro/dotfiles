# Real-World Skill Examples

This guide shows real implementations and patterns to learn from.

---

## Example 1: RsDT Skill (Complex, Reference-Heavy)

**Location**: `dot_claude/skills/RsDT/SKILL.md` (681 lines)

**Pattern**: Large, comprehensive workflow Skill

### Structure:
```
RsDT/
└── SKILL.md (681 lines)
```

### What Makes It Work:
- **Clear phases**: Draft → Implementation → Archive
- **Detailed checklists**: TodoWrite integration, mandatory review steps
- **Progressive structure**: Overview → Detailed workflow → Implementation guidelines
- **Japanese content**: All generated files in Japanese (domain-specific choice)
- **TDD integration**: Mandatory test-first approach

### Key Lessons:
1. **Large Skill works when**: Content is deeply structured with multiple phases
2. **Self-referential**: The Skill explains how to use itself (meta)
3. **Directive language**: Uses imperative style for clarity ("MUST", "Always")
4. **File references**: Minimal external files (mostly self-contained)

### Discovery:
```yaml
name: RsDT
description: Specification-driven development workflow for creating requirements, design, and tasks...
```
- Clear what it does (specification-driven workflow)
- Clear when to use (planning features, fixing bugs, refactoring)

---

## Example 2: Simple Skill Pattern (PDF Processing)

**Hypothetical Pattern**: Basic utility Skill

### Structure:
```
processing-pdfs/
├── SKILL.md (180 lines)
├── ADVANCED.md (100 lines)
└── scripts/
    └── extract_text.py
```

### Example SKILL.md Content:

```markdown
---
name: processing-pdfs
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or or document extraction.
---

# Processing PDFs

## Quick Start

Extract text from a PDF using pdfplumber:

```python
import pdfplumber

with pdfplumber.open("invoice.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Key Concepts

- **pdfplumber**: Python library for PDF text extraction
- **Tables**: Use `pdf.pages[0].extract_tables()` for tabular data
- **Forms**: See [ADVANCED.md](ADVANCED.md) for form filling

## Common Workflows

### Workflow 1: Extract All Text
```python
with pdfplumber.open("file.pdf") as pdf:
    all_text = "\n".join(page.extract_text() for page in pdf.pages)
```

### Workflow 2: Extract Tables
```python
with pdfplumber.open("file.pdf") as pdf:
    tables = pdf.pages[0].extract_tables()
```

### Workflow 3: Merge Multiple PDFs
```python
from PyPDF2 import PdfMerger
merger = PdfMerger()
for pdf_file in ["file1.pdf", "file2.pdf"]:
    merger.append(pdf_file)
merger.write("output.pdf")
```

## Examples

**Input**: PDF invoice with customer name, amount, date
**Output**: Extracted fields as JSON
```json
{
  "customer": "Acme Corp",
  "amount": "$1,500",
  "date": "2024-01-15"
}
```

## Advanced Features

For complex form filling and custom extraction rules, see [ADVANCED.md](ADVANCED.md).

For complete pdfplumber API reference, see [REFERENCE.md](REFERENCE.md).
```

### Key Lessons:
1. **Concise**: Only 180 lines in SKILL.md (under 300 target)
2. **Quick Start first**: Users see minimal working example immediately
3. **Progressive reference**: Links to ADVANCED.md and REFERENCE.md only when needed
4. **Practical workflows**: Real-world patterns users would actually use

---

## Example 3: Multi-Domain Skill Pattern

**Pattern**: Skill with multiple, independent domains

### Structure:
```
data-analysis/
├── SKILL.md (200 lines - navigation)
├── reference/
│   ├── finance.md (revenue, billing metrics)
│   ├── sales.md (pipeline, opportunities)
│   ├── product.md (API usage, features)
│   └── marketing.md (campaigns, attribution)
└── scripts/
    └── query_generator.py
```

### Example SKILL.md Navigation:

```markdown
---
name: data-analysis
description: Analyze business data across finance, sales, product, and marketing domains. Use when analyzing metrics, pipelines, usage, or campaigns.
---

# Data Analysis

## Quick Start

Query sales pipeline data:

```sql
SELECT COUNT(*) as total_opps, SUM(amount) as total_value
FROM sales.opportunities
WHERE stage != 'closed_lost'
```

## Available Datasets

Choose your domain:

- **Finance**: Revenue, ARR, billing metrics → See [reference/finance.md](reference/finance.md)
- **Sales**: Opportunities, pipeline, accounts → See [reference/sales.md](reference/sales.md)
- **Product**: API usage, features, adoption → See [reference/product.md](reference/product.md)
- **Marketing**: Campaigns, attribution, email → See [reference/marketing.md](reference/marketing.md)

## Search Available Metrics

```bash
grep -i "revenue" reference/finance.md
grep -i "pipeline" reference/sales.md
```

## Common Queries

See reference files for domain-specific query patterns.
```

### Key Lessons:
1. **SKILL.md stays lean**: Only 200 lines (navigation + overview)
2. **Domain files bundled but unloaded**: Claude reads only relevant domain files
3. **High context efficiency**: Multiple domains, but token usage stays low
4. **User can self-navigate**: Grep suggestions for finding metrics

---

## Example 4: Script-Centric Skill Pattern

**Pattern**: Skill that wraps executable utilities

### Structure:
```
form-processing/
├── SKILL.md (150 lines)
├── REFERENCE.md (80 lines)
└── scripts/
    ├── analyze_form.py
    ├── validate_fields.py
    ├── fill_form.py
    └── verify_output.py
```

### Example Workflow in SKILL.md:

```markdown
## PDF Form Processing Workflow

1. **Analyze Form**
   Run: `python scripts/analyze_form.py input.pdf`
   Output: JSON file listing all form fields

2. **Create Field Mapping**
   Edit: `fields.json` to add values for each field

3. **Validate Mapping**
   Run: `python scripts/validate_fields.py fields.json`
   Checks: Required fields, data types, constraints

4. **Fill Form**
   Run: `python scripts/fill_form.py input.pdf fields.json output.pdf`
   Output: Filled PDF saved to output.pdf

5. **Verify Result**
   Run: `python scripts/verify_output.py output.pdf`
   Confirms: All fields filled correctly
```

### Key Lessons:
1. **Scripts don't load into context**: Only execution output matters
2. **Deterministic operations**: Scripts ensure consistency better than generated code
3. **Clear workflow**: Step-by-step instructions make scripts easy to use
4. **Error handling**: Scripts handle errors; Claude just runs them
5. **Efficiency**: Scripts save tokens vs. generating equivalent code

---

## Example 5: Evaluation-Driven Development

### How to Develop a Skill (Recommended Process)

**Step 1: Create Evaluations First**

```json
{
  "skill_name": "processing-pdfs",
  "evaluation_1": {
    "query": "Extract all text from this PDF and save to output.txt",
    "files": ["sample.pdf"],
    "expected_behavior": [
      "Successfully reads PDF using pdfplumber",
      "Extracts text from all pages",
      "Saves to output.txt in readable format"
    ]
  },
  "evaluation_2": {
    "query": "Extract the pricing table from this PDF as JSON",
    "files": ["pricing.pdf"],
    "expected_behavior": [
      "Identifies table structure",
      "Extracts all rows and columns",
      "Converts to valid JSON format"
    ]
  },
  "evaluation_3": {
    "query": "What happens if I give you a corrupted PDF?",
    "files": ["corrupted.pdf"],
    "expected_behavior": [
      "Gracefully handles error",
      "Explains the issue",
      "Suggests alternative approaches"
    ]
  }
}
```

**Step 2: Measure Without Skill**
- Try the tasks with Claude but no Skill
- Note where Claude struggles
- Document missing context

**Step 3: Create Minimal Skill**
- Address only the gaps
- Keep SKILL.md concise
- Include examples

**Step 4: Test with Skill**
- Run evaluations with your Skill enabled
- Verify improvement over baseline
- Iterate based on failures

**Step 5: Refine**
- Add detail only where testing revealed gaps
- Remove unnecessary content
- Test again

---

## Pattern Comparison

| Pattern | Size | Use Case | Complexity | File Refs |
|---------|------|----------|-----------|-----------|
| Minimal | ~100 lines | Simple utility | Low | 0 |
| Standard | ~250 lines | Most Skills | Medium | 2-3 |
| Reference-Heavy | ~200 SKILL + 500+ refs | Complex domains | High | Multiple |
| Script-Centric | ~150 lines + scripts | Deterministic ops | Medium | Scripts |
| Multi-Domain | ~200 lines + domains | Large systems | High | By domain |

---

## Quick Checklist: Is Your Example Good?

- [ ] Shows actual use case (not abstract)
- [ ] Input/output are realistic
- [ ] Code runs without modification
- [ ] Demonstrates key concept or workflow
- [ ] Concise (not a novel)
- [ ] Matches Skill's target use case

---

## Meta-Skill Example: This Skill Itself

The `creating-skills` Skill you're reading is itself an example of a reference-heavy, multi-file Skill:

```
creating-skills/
├── SKILL.md (overview + quick start)
├── PLANNING.md (planning template)
├── BEST_PRACTICES.md (best practices summary)
├── STRUCTURE.md (file organization guide)
├── EXAMPLES.md (this file - real examples)
├── templates/
│   ├── SKILL_TEMPLATE.md
│   └── CHECKLIST.md
└── scripts/
    └── (future: validation scripts)
```

**Why this structure works**:
1. **SKILL.md**: Quick start + navigation
2. **PLANNING.md**: Template to fill out (actionable)
3. **BEST_PRACTICES.md**: Condensed best practices from official docs
4. **STRUCTURE.md**: Patterns for organizing Skill files
5. **EXAMPLES.md**: Real implementations to learn from
6. **templates/**: Ready-to-use templates

Each file is referenced only when needed, keeping context efficient.

---

## Next Steps

1. Choose a pattern that fits your Skill
2. Review the example structure
3. Fill out [PLANNING.md](PLANNING.md) for your Skill
4. Use [SKILL_TEMPLATE.md](../templates/SKILL_TEMPLATE.md) to create SKILL.md
5. Validate with [CHECKLIST.md](../templates/CHECKLIST.md)
6. Add to settings.json and test
