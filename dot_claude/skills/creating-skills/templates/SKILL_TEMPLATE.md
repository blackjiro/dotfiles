---
name: your-skill-name
description: What this Skill does and when to use it (include both what and when - max 1024 chars)
---

# Your Skill Name

## Quick Start

[Keep this section minimal - show one simple, working example that demonstrates the core capability]

```python
# Example: Show the most basic use case
import your_library

result = your_library.do_something("input")
print(result)
```

## Key Concepts

[Explain the fundamental ideas Claude needs to understand to use this Skill effectively]

- **Concept 1**: [What it is and why it matters]
- **Concept 2**: [Important distinction or pattern]
- **Concept 3**: [Common terminology]

## Common Workflows

[Provide step-by-step instructions for the main use cases]

### Workflow 1: [First Common Task]

```python
# Step-by-step example
step1 = setup()
step2 = process(step1)
result = finalize(step2)
```

### Workflow 2: [Second Common Task]

```python
# Alternative pattern
result = alternative_approach()
```

### Workflow 3: [Third Common Task]

```python
# Another common pattern
result = yet_another_way()
```

## Examples

### Example 1: Basic Usage

**Input:**
```
Sample input data
```

**Expected Output:**
```json
{
  "result": "output",
  "status": "success"
}
```

**Code:**
```python
# Implementation example
result = your_function("input")
```

### Example 2: Advanced Scenario

**Input:**
```
More complex input
```

**Expected Output:**
```json
{
  "result": "output",
  "details": "explanation"
}
```

**Code:**
```python
# Implementation with options
result = your_function("input", option=True)
```

## Configuration & Options

[List key configuration options if applicable]

| Option | Type | Default | Purpose |
|--------|------|---------|---------|
| option1 | string | "value" | [What does it do?] |
| option2 | int | 100 | [What does it do?] |
| option3 | bool | False | [What does it do?] |

## Error Handling

[Explain how this Skill handles errors and what to do if things go wrong]

**Common Issues:**
- Issue 1: [Symptom] → Solution: [Fix]
- Issue 2: [Symptom] → Solution: [Fix]

For more troubleshooting, see [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) (if applicable).

## Advanced Topics

[Reference detailed content in separate files rather than including here]

For complex patterns and optimization, see [ADVANCED.md](../ADVANCED.md).

For complete API reference, see [REFERENCE.md](../REFERENCE.md).

## Related Resources

[Links to relevant documentation or skills]

- [Official Documentation](https://example.com)
- [GitHub Repository](https://github.com/example)
- Related Skill: [another-skill](../../another-skill/SKILL.md)

---

## Notes for Authors

**Before Publishing:**
- [ ] SKILL.md is ≤300 lines total
- [ ] Name is lowercase, kebab-case (e.g., `processing-pdfs`)
- [ ] Description includes both "what" and "when to use"
- [ ] Quick Start shows minimal, working example
- [ ] Examples include realistic input/output
- [ ] All external file references are one level deep
- [ ] No XML tags in name or description
- [ ] Tested with actual use cases

**Sections to Keep/Remove:**
- Keep: Quick Start, Key Concepts, Common Workflows, Examples
- Remove or simplify: Sections that don't apply to your Skill
- Link: Configuration/Advanced content to separate reference files instead of embedding

**Keep It Concise:**
- Assume Claude already knows basics (no need to explain what a variable is)
- Use bullet points, not paragraphs
- Show examples instead of describing concepts
- Reference external docs for deep dives

---

## Template Usage

1. **Copy this file**: Save as `your-skill-name/SKILL.md`
2. **Fill sections**: Work through each section with your content
3. **Customize structure**: Add/remove sections as needed
4. **Remove this "Notes" section**: Delete before publishing
5. **Validate**: Use [CHECKLIST.md](./CHECKLIST.md)
6. **Integrate**: Add to settings.json and test
