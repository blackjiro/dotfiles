---
allowed-tools: Bash(gh:*), Bash(git:*), Read, Grep, Glob, LS, WebFetch, mcp__github__list_repositories, mcp__github__list_commits, mcp__github__get_commit
description: "GitHub organizationの本日のコミットを分析し、マーケティング向けSNS投稿を生成"
---

# Daily Development Progress for SNS

今日のGitHub上の開発進捗を分析し、マーケティング効果の高いSNS投稿文を生成します。

## 実行内容

1. **リポジトリ一覧の取得**
   - prime-consulting-inc organizationの全リポジトリを取得
   - アクティブなリポジトリを特定

2. **今日のコミット分析**
   - 各リポジトリの本日のコミットを収集
   - コミットメッセージから主要な変更点を抽出
   - 技術的成果をマーケティング視点で解釈

3. **SNS投稿文の生成**
   - 140文字以内の効果的な投稿文を3-5パターン生成
   - 技術的成果を分かりやすく表現
   - ハッシュタグの提案を含む

4. **画像キャプチャの提案**
   - 投稿に効果的な画像の種類を提案
   - 具体的なキャプチャ方法を説明

## 2025-08-02 Development Progress Report

### Active Repositories (16 total)
**Most Active Today:**
1. **hojokin-crawler-poc** (Python) - Last updated: 12:17:01Z
2. **ipo-navi** (Svelte) - Last updated: 06:45:59Z

### Today's Technical Achievements

#### 🚀 hojokin-crawler-poc Repository
**5 commits by Hiroki Goto:**

1. **Merged branch 'change-top-page-structure'** (12:11:43Z)
2. **Expanded Tokyo area coverage** (11:53:26Z)
   - Added 13 new institutions including 東京都中小企業振興公社
   - Added ward-level coverage: 江東区, 目黒区, 大田区, 世田谷区, 渋谷区, 中野区, 杉並区
   - **Total coverage: 16 active institutions**

3. **Configuration restructure** (11:14:52Z)
   - Replaced 'top_pages' with flexible 'institutions' structure
   - Added InstitutionConfig class supporting multiple URLs per institution
   - Improved maintainability and configuration flexibility

4. **Institution name preservation** (06:37:55Z)
   - Enhanced data integrity by preserving institution names from list to detail pages
   - Improved batch processing with proper institution associations

#### 🌐 ipo-navi Repository
**3 commits + 1 merged PR by Hiroki Goto:**

1. **PR #168 Merged: WWW domain redirect implementation** (06:45:55Z)
   - Implemented automatic redirect from www.ipo-navi.jp to ipo-navi.jp
   - Added 301 permanent redirect with path/query preservation
   - Improved SEO and user experience

2. **Domain mapping enhancement** (06:13:08Z)
3. **robots.txt optimization** (05:48:15Z)

### Workflow Activity
- **8 successful CI/CD runs** for ipo-navi today
- **2 failed runs** resolved through iteration (showing robust testing process)

### Marketing Insights
**Key Achievements for SNS:**
- **Geographic Expansion**: 13 new Tokyo institutions added to subsidy crawler
- **Technical Excellence**: Multi-URL institution support showing scalable architecture
- **User Experience**: SEO optimization with proper domain redirects
- **Data Integrity**: Enhanced preservation of institutional metadata

## 使用例

```
/marketing:daily-dev-progress
```

## 投稿文生成のポイント

- 専門用語を適度に使いつつ、一般の人にも理解しやすい表現
- 具体的な数値や成果を含める
- トレンドのハッシュタグを活用
- エンゲージメントを促す質問形式も検討