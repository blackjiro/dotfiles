
## TIPS
### 1password
#### 機密情報をdocumentとして保存する場合
```sh
export PATH_FROM_HOME=.ssh/id_rsa
chezmoi add --template ~/$PATH_FROM_HOME
op document create ~/$PATH_FROM_HOME --tags chezmoi --title $PATH_FROM_HOME --vault dev
```
上記で出力されたuuidをtemplateで取得する

```
{{- onepasswordDocument "<uuid>" -}}
```

#### 機密情報をセキュアノートで保存する場合
1. ノート名を設定 `export TITLE=<タイトル>`
2. `op item create --vault dev --category "SECURE NOTE" --title $TITLE` で作成
3. GUIで中身を編集
4. `{{ onepasswordRead "op://dev/<タイトル>/notesPlain" }}` で読み込む

### 外部から変更されるファイルの設定
- [参照](https://www.chezmoi.io/user-guide/manage-different-types-of-file/#handle-configuration-files-which-are-externally-modified)

以下karabinerの例
```sh
export FILE_NAME=karabiner.json
export DIR_PATH_FROM_HOME=.config/karabiner/$FILE_NAME
cp $DIR_PATH_FROM_HOME $(chezmoi source-path)/symlinked
# ディレクトリが存在しない場合は作成
# chezmoi add $DIR_PATH_FROM_HOME
# 以下ディレクトリは上記で生成されたディレクトリ
export SOURCE_DIR=$(chezmoi source-path)/dot_config/private_karabiner
echo -n "{{ .chezmoi.sourceDir }}/symlinked/$FILE_NAME" > $SOURCE_DIR/symlink_$FILE_NAME.tmpl
chezmoi apply -v
```
