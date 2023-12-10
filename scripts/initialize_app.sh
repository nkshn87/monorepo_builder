#!/bin/bash

# 引数の取得
appName=$1

appDir="apps/$appName"
rootDir=../../..
jsonFile="package.json"

mkdir -p "$appDir"
cd "$appDir" || exit
pnpm init > /dev/null 2>&1 || exit

jq '.main = "./dist/index.js" | .scripts.build = "tsc ./src/index.ts --outDir ./dist --declaration"' "$jsonFile" > temp.json && mv temp.json "$jsonFile"

pnpm add -D typescript || exit
pnpm add database ui libs || exit

# ソースディレクトリの作成とテンプレートのコピー
mkdir -p "./src"
cp "$rootDir/configs/apps/index.ts" "./src" || exit

cd ../../ || exit
