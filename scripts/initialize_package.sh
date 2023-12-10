#!/bin/bash

# 引数の取得
packageName=$1

packageDir="packages/$packageName"
rootDir=../../..
jsonFile="package.json"

mkdir -p "$packageDir"
cd "$packageDir" || exit
pnpm init > /dev/null 2>&1 || exit

jq '.main = "./dist/index.js" | .scripts.build = "tsc ./src/index.ts --outDir ./dist --declaration"' "$jsonFile" > temp.json && mv temp.json "$jsonFile"

pnpm add -D typescript || exit

# ソースディレクトリの作成とテンプレートのコピー
mkdir -p "./src"
cp "$rootDir/configs/packages/index.ts" "./src" || exit

cd ../../ || exit
