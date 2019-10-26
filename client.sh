#!/bin/sh

# 開始メッセージ
echo '- kurumi-clientを実行します..'

# 現在のディレクトリの絶対パス取得
# CURRENT_PATH=$(cd $(dirname $0) && pwd)

# `kurumi-crawler`のパス
CRAWLER_PATH=../kurumi-crawler/
# `node`のパス
NODE_PATH=/Users/kanegadai/.nodebrew/current/bin/node
# POST用のcurlコマンド
CURL_POST='/usr/bin/curl -H "Content-Type: application/json"'
# POST先のURL
URL=http://localhost:3000/withdrawals

# クローラー下の"更新日付が3日以前"のファイルを削除
# （xargs >> 標準入力からコマンドを作成）
echo '- 3日以前のクローリング結果ファイルを削除します..'
find ${CRAWLER_PATH}json/ -name "*.json" -mtime +3 -print | xargs rm;

# `../kurumi-crawler/dist/index.js`をキックする
echo '- kurumi-crawlerを実行します..'
# cd ${CRAWLER_PATH} && ${NODE_PATH} ./dist/index.js

if [ $? -eq 0 ]
then
    # クローラー下の"更新日付が当日"のファイルをcurlでP0STする
    echo '- POSTを実行します..'
    for file in `find ${CRAWLER_PATH}json/ -name "*.json" -mtime 0 -print`; do
        ${CURL_POST} ${URL} -d @${file}
    done
else
    # nodeの戻り値が不正だった場合、slackへ通知して処理終了 >> slackへの通知を別スクリプトにする
    echo '- クローリングに失敗しました。kurumi-clawler実行結果を確認してください..'
fi
