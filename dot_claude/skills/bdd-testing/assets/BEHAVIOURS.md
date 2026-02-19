# BEHAVIORS

## ユーザー登録 (POST /api/users)

### 正常系

- GIVEN: 有効なメールアドレスとパスワード
  WHEN: 登録APIを呼ぶ
  THEN: 201が返り、ユーザーが作成される
  AND: ウェルカムメールが送信される

### 異常系

- GIVEN: 既に登録済みのメールアドレス
  WHEN: 登録APIを呼ぶ
  THEN: 409エラーが返る

- GIVEN: 不正なメールアドレス形式
  WHEN: 登録APIを呼ぶ
  THEN: 400エラーが返る

- GIVEN: パスワードが8文字未満
  WHEN: 登録APIを呼ぶ
  THEN: 400エラーが返る

- GIVEN: 必須フィールド（メールアドレス）が未入力
  WHEN: 登録APIを呼ぶ
  THEN: 400エラーが返る

### 境界値

- GIVEN: パスワードがちょうど8文字
  WHEN: 登録APIを呼ぶ
  THEN: 201が返り、ユーザーが作成される

## ユーザー取得 (GET /api/users/:id)

### 正常系

- GIVEN: 認証済みのユーザー
  AND: 存在するユーザーID
  WHEN: 取得APIを呼ぶ
  THEN: 200とユーザー情報が返る

### 異常系

- GIVEN: 存在しないユーザーID
  WHEN: 取得APIを呼ぶ
  THEN: 404エラーが返る

- GIVEN: 認証なし
  WHEN: 取得APIを呼ぶ
  THEN: 401エラーが返る
