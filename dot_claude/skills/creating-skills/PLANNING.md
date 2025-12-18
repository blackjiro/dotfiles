# Skill Planning Template

このテンプレートを使用して、新しい Skill を設計・企画します。実装に移る前に、各セクションを埋めることで、明確で発見可能な Skill を確実に作成できます。

---

## 基本情報

### Skill Name（スキル名）

**候補名**: [proposed name]

**ガイドライン**:
- Gerund form（動詞-ing形）推奨: `processing-pdfs`, `analyzing-spreadsheets`
- 小文字、数字、ハイフンのみ使用
- 最大 64 文字
- 具体的で発見可能な名前

**採用名**:

---

## Purpose & Scope（目的と範囲）

### What Problem Does This Skill Solve?

このスキルが解決する問題を説明してください。

**問題**:

**その問題が重要な理由**:

### What's Included (In Scope)

実装する機能・サポート範囲:

- [ ]
- [ ]
- [ ]

### What's Excluded (Out of Scope)

実装しない、または後回しにする項目:

- [ ]
- [ ]

---

## Target Users & Use Cases（ターゲットユーザーと使用シーン）

### Who Uses This Skill?

誰がこのスキルを使用するか：

**Primary Audience**:

**Secondary Audience** (if any):

### Primary Use Cases

最も重要な 2-3 の使用シーン:

**Use Case 1: [Scenario Name]**
- User Action: [何をしたいのか]
- Expected Outcome: [期待される結果]

**Use Case 2: [Scenario Name]**
- User Action: [何をしたいのか]
- Expected Outcome: [期待される結果]

**Use Case 3: [Scenario Name]**
- User Action: [何をしたいのか]
- Expected Outcome: [期待される結果]

---

## Skill Discovery（スキル発見）

### Description（説明文）

SKILL.md の Frontmatter に入る Description。発見性を高めるため、"何ができるか"と"いつ使うか"を含める：

**Proposed Description**:

> [Your description here - max 1024 chars]

**Checklist**:
- [ ] 何ができるかが明記されている
- [ ] いつ使うかが明記されている
- [ ] 1024 文字以下
- [ ] XML タグなし
- [ ] 具体的で曖昧でない

---

## Information Architecture（情報設計）

### What Will SKILL.md Cover?

SKILL.md 本体に含めるべき主要な内容:

- [ ] Quick Start / 最小限の例
- [ ] 主要なコンセプト
- [ ] 基本的なワークフロー
- [ ] 例（input/output）
- [ ] 他の詳細ファイルへのリンク

### Will You Need Reference Files?

SKILL.md 本体の外に、詳細情報が必要か：

- [ ] ADVANCED.md - 高度な使用法
- [ ] REFERENCE.md - API 詳細
- [ ] EXAMPLES.md - 豊富な例
- [ ] TROUBLESHOOTING.md - よくある問題と解決策
- [ ] TEMPLATES.md - テンプレート集

**理由**:

---

## Progressive Disclosure Design（段階的情報開示）

### Level 1: Metadata
システムプロンプトに含まれる情報:
```
name: [skill-name]
description: [one-line summary + when to use]
```

### Level 2: SKILL.md Body
Skill がトリガーされたときに読み込まれる情報:
- Quick Start section
- Key concepts
- Common workflows

**推定行数**: 150-300 行

### Level 3: Reference Files
必要に応じて読み込まれるファイル:
- ADVANCED.md
- REFERENCE.md
- EXAMPLES.md

---

## Naming & Conventions（命名・規約）

### Skill Name

**Gerund form**: [e.g., processing-pdfs]

**Kebab-case**: ✓ (hyphens, lowercase)

### File Naming Within Skill

```
creating-skills/
├── SKILL.md (main content)
├── PLANNING.md (this file)
├── BEST_PRACTICES.md (reference)
├── STRUCTURE.md (patterns)
├── EXAMPLES.md (real implementations)
├── templates/
│   ├── SKILL_TEMPLATE.md
│   └── CHECKLIST.md
└── scripts/
    └── validate_skill.py
```

---

## Implementation Feasibility（実装可能性）

### Can This Be Built?

実装に必要なものを確認:

- [ ] 外部ライブラリが利用可能か？(context7 で確認した)
- [ ] API が安定しているか？
- [ ] Claude Code の制限内か？(file access, bash, code execution)

**課題や制限事項**:

### Effort Estimate

- SKILL.md: ~2-4 hours
- Reference files: ~1-2 hours each
- Testing/refinement: ~1-2 hours

**Total**: ~5-10 hours

---

## Dependencies & External Tools（依存関係と外部ツール）

### External Libraries/APIs

このスキルが使用するライブラリや API:

| Library/API | Purpose | Status | Notes |
|-------------|---------|--------|-------|
| [e.g., pdfplumber] | [e.g., PDF text extraction] | ✓ Available | [Version info] |
| | | | |

### MCP Servers

使用する MCP サーバー（あれば）:

- [ ] context7 (library documentation)
- [ ] WebSearch
- [ ] WebFetch
- [ ] Other: ___________

---

## Next Steps（次のステップ）

Planning が完了したら：

1. ✓ [このテンプレートを完成させた]
2. → SKILL_TEMPLATE.md を使用して SKILL.md を作成
3. → BEST_PRACTICES.md, STRUCTURE.md などの参照ファイルを作成
4. → settings.json に skill を登録
5. → 実際に使用して動作確認
6. → CHECKLIST.md で品質確認

---

## Example: Completed Planning（完成例）

参考までに、完成した Planning の例:

### Skill Name
`processing-pdfs`

### Purpose
PDF ファイルからテキストと表を抽出し、フォームを埋め、ドキュメントをマージします。

### Use Cases
1. 複数ページの PDF から情報を抽出
2. フォームに自動入力
3.複数の PDF を 1 ファイルにマージ

### Description
"Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."

このようなレベルの明確さを目指しましょう。
