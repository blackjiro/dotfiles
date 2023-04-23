# Dotfiles
[chezmoi](https://www.chezmoi.io/) + [Homebrew](https://brew.sh/)

## Steps
1. execute `./bootstrap.sh`
2. setup 1password : [instruction](https://developer.1password.com/docs/cli/get-started/)
3. re bootstrap (only for mac)
4. setup tmux (<C-t> I)
5. setup yabai / skhd

### Raycast設定
1. Dropboxを設定する
2. DropboxからRaycastの最新のconfigをimportする

## TODO
- [ ] Linux環境でもGUI以外の環境が構築できるようにする。 (GitHub Codespace or GitPod)
- [ ] 複数環境で動くことを担保するため、CIを作成する。

# 調整が必要
- Rustの設定もスクリプトにする
- CI/CD書く

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
```
