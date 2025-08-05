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
   - ghコマンドを利用

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

## 使用例

```
/marketing:daily-dev-progress
```

## 投稿文生成のポイント

- 専門用語を適度に使いつつ、一般の人にも理解しやすい表現
- 具体的な数値や成果を含める
- トレンドのハッシュタグを活用
- エンゲージメントを促す質問形式も検討
