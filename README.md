# Dotfiles
[chezmoi](https://www.chezmoi.io/) + [Homebrew](https://brew.sh/)

## Steps
1. execute `./bootstrap.sh`
2. setup 1password : [instruction](https://developer.1password.com/docs/cli/get-started/)
3. re bootstrap (only for mac)

### Raycast設定
1. Dropboxを設定する
2. DropboxからRaycastの最新のconfigをimportする

## TODO
- [ ] Linux環境でもGUI以外の環境が構築できるようにする。 (GitHub Codespace or GitPod)
- [ ] 複数環境で動くことを担保するため、CIを作成する。

# 調整が必要
- [starshipにしてみる](https://gist.github.com/ryo-ARAKI/48a11585299f9032fa4bda60c9bba593)
-  tmux.confを整理
- Yabaiの設定手順をor fileを書く
- karabinarのGUIからの変更を反映できるようにする
- Rustの設定もスクリプトにする
- CI/CD書く

## TIPS
### 1password
add secure items
```sh
export PATH_FROM_HOME=.ssh/id_rsa
chezmoi add --template ~/$PATH_FROM_HOME
op document create ~/$PATH_FROM_HOME --tags chezmoi --title $PATH_FROM_HOME --vault dev
```
上記で出力されたuuidをtemplateで取得する
```
{{- onepasswordDocument "<uuid>" -}}
```
