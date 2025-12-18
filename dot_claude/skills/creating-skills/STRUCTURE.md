# Skill File Structure & Organization

This guide covers how to organize files within your Skill directory for maximum clarity and efficiency.

---

## Choose Your Pattern

Decide which pattern fits your Skill:

```
Simple Skill?
└─ YES → Use Pattern 1 (Minimal)
└─ NO → Is it script-heavy or multi-domain?
   └─ YES → Use Pattern 2 (Standard with Scripts/Domain)
   └─ NO → Use Pattern 3 (Reference-Heavy)
```

---

## Pattern 1: Minimal Skill

**Use when**: Content fits in one file, simple utility, quick reference

```
your-skill/
└── SKILL.md (100-200 lines)
```

**Characteristics**:
- Single SKILL.md file
- No external references
- Load time: instant
- Token cost: ~2-5k

---

## Pattern 2: Standard Skill (with Scripts or Domains)

**Use when**: You need scripts OR multiple domains, but not both extensively

### Option 2A: Script-Centric
```
your-skill/
├── SKILL.md (150-200 lines)
├── ADVANCED.md (optional, 100+ lines)
└── scripts/
    ├── analyze.py
    ├── validate.py
    └── utils/
        └── helpers.py
```

**Key Points**:
- Scripts are executed, not loaded into context
- Only output consumes tokens
- SKILL.md shows how to run each script

### Option 2B: Domain-Organized
```
your-skill/
├── SKILL.md (150-200 lines, navigation)
└── reference/
    ├── finance.md
    ├── sales.md
    ├── product.md
    └── marketing.md
```

**Key Points**:
- SKILL.md navigates to relevant domains
- Claude reads only domain files needed
- Efficient token usage

---

## Pattern 3: Reference-Heavy Skill

**Use when**: Complex API, multiple topics, extensive examples needed

```
your-skill/
├── SKILL.md (200-250 lines, overview + quick start)
├── ADVANCED.md (advanced patterns, edge cases)
├── REFERENCE.md (complete API, all options)
├── EXAMPLES.md (input/output samples)
├── TROUBLESHOOTING.md (FAQ, common issues)
└── scripts/ (optional)
    └── validate.py
```

**Key Points**:
- SKILL.md stays concise (entry point)
- Reference files loaded on-demand
- Progressive disclosure: metadata → SKILL.md → reference files
- Token cost: SKILL.md (~2-5k) + reference files as needed

---

## File Naming & Conventions

### Reference File Naming

| Filename | Purpose | When Loaded |
|----------|---------|-------------|
| `SKILL.md` | Main instructions | Always (when Skill triggers) |
| `ADVANCED.md` | Complex patterns, edge cases | On-demand |
| `REFERENCE.md` | Complete API, all options | On-demand |
| `EXAMPLES.md` | Input/output samples | On-demand |
| `TROUBLESHOOTING.md` | FAQ, common issues | On-demand |

**Rules**:
- Use UPPERCASE for markdown files
- Use snake_case for scripts (validate.py, not Validate.py)
- Avoid generic names (not doc1.md, file2.md)
- Keep names descriptive

### Directory Organization

```
your-skill/
├── SKILL.md              # Always required
├── reference/            # (optional) Organize by domain
│   ├── finance.md
│   └── sales.md
├── templates/            # (optional) Reusable templates
│   └── basic.md
└── scripts/              # (optional) Executable utilities
    └── helper.py
```

---

## Quick Reference

### SKILL.md Structure

```markdown
---
name: your-skill-name
description: What it does and when to use it
---

# Skill Name

## Quick Start
[Minimal example]

## Key Concepts / Workflows
[Main content]

## Examples
[Input/output pairs]

## Reference
[Links to other files]
```

### File Size Guidelines

| File | Target | Notes |
|------|--------|-------|
| SKILL.md | 150-300 lines | Entry point, keep concise |
| Reference files | No limit | Loaded on-demand, no token penalty |
| Scripts | Self-contained | Executed, not loaded |

### Key Rules

- ✅ SKILL.md ≤300 lines
- ✅ Reference files one level deep (no nested links)
- ✅ Use relative paths: `[ADVANCED](ADVANCED.md)`
- ✅ Use forward slashes: `scripts/helper.py`
- ✅ Uppercase for markdown: `ADVANCED.md`
- ✅ Snake_case for scripts: `validate.py`
- ✅ Scripts have error handling & documentation

---

## Settings.json Integration

To enable your Skill in Claude Code, add to `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Skill(creating-skills)",
      "Skill(your-skill-name)"
    ]
  }
}
```

---

## Example: Complete Reference-Heavy Skill

```
processing-pdfs/
├── SKILL.md (250 lines)
├── ADVANCED.md (advanced patterns)
├── REFERENCE.md (complete API)
├── EXAMPLES.md (use cases)
├── TROUBLESHOOTING.md (FAQ)
└── scripts/
    ├── extract_text.py
    └── validate_form.py
```

**Key Principle**: Progressive disclosure keeps content efficient. Bundle everything, load only what's needed. Organize for clarity, name for discovery, reference strategically.
