#!/bin/bash

rootDir=../
scriptDir="$rootDir/scripts"
configDir="$rootDir/configs"
packageJsonFile="package.json"

mkdir monorepo_temp
cd monorepo_temp || exit
pnpm init > /dev/null 2>&1 || exit

# pnpmのバージョンを強制する設定を追記
jq --slurpfile addConfig "$configDir/add_package.json" '. + $addConfig[0]' "$packageJsonFile" > temp.json && mv temp.json "$packageJsonFile"  || exit

# pnpm-workspaceで管理するパッケージを指定
cp "$configDir/pnpm-workspace.yaml" "." || exit

# 各パッケージの初期化
"$scriptDir/initialize_package.sh" "database" || exit
"$scriptDir/initialize_package.sh" "ui" || exit
"$scriptDir/initialize_package.sh" "libs" || exit

# 各アプリの初期化
"$scriptDir/initialize_app.sh" "admin" || exit
"$scriptDir/initialize_app.sh" "user" || exit

# Turborepoの設定ファイルをコピー
cp "$configDir/turbo.json" "." || exit

# buildコマンドを一括実行できるようTurborepoのインストール
# ルートにインストールする場合は`-w, --workspace-root`が必要
pnpm add -w -D turbo

# package.jsonにビルドスクリプトを追加
jq '.scripts |= . + {"build": "turbo build"}' "$packageJsonFile" > temp.json && mv temp.json "$packageJsonFile"  || exit

# ビルドの実行
pnpm build || exit
# Turborepoが提供する`build`コマンドを実行することで、
# 以下のビルドを依存関係を考慮して良しなに実行してくれる。＆結果をキャッシュして高速にしてくれる。便利〜
# pnpm --filter database build
# pnpm --filter ui build
# pnpm --filter libs build
# pnpm --filter admin build
# pnpm --filter user build

node apps/admin/dist/index.js
node apps/user/dist/index.js