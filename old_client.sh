#!/bin/sh

# 開始メッセージ
echo '- kurumi-clientを実行します..'

# `node`のパス
NODE_PATH=/Users/kanegadai/.nodebrew/current/bin/node
# POST用の`curl`コマンド
CURL_POST='/usr/bin/curl -H "Content-Type: application/json"'
# `kurumi-crawler`のパス
CRAWLER_PATH=/Users/kanegadai/Documents/MyDesk/02_develop/kurumi-crawler/
# DEBUG用のPOST先（json-server）
# URL=http://localhost:3000/withdrawals
# 本番のPOST先
URL=https://xjzv8xncp7.execute-api.ap-northeast-1.amazonaws.com/kurumi

# クローラー下の"更新日付が3日以前"のファイルを削除
# （xargs >> 標準入力からコマンドを作成）
echo '- 3日以前のクローリング結果ファイルを削除します..'
find ${CRAWLER_PATH}json/ -name "*.json" -mtime +3 -print | xargs rm;

# `../kurumi-crawler/dist/index.js`をキックする
echo '- kurumi-crawlerを実行します..'
cd ${CRAWLER_PATH} && ${NODE_PATH} ./dist/src/index.js

echo '- クローリング結果 >> '$?
if [ $? -eq 0 ]
then
    # クローラー下の"更新日付が当日"のファイルをcurlでP0STする
    echo '- POSTを実行します..'
    for file in `find ${CRAWLER_PATH}json/ -name "*.json" -mtime 0 -print`; do
        # `curl`の標準出力は捨てる
        ${CURL_POST} ${URL} -d @${file} >/dev/null
    done
    echo '- POSTが終了しました..'
else
    # nodeの戻り値が不正だった場合、slackへ通知して処理終了 >> slackへの通知を別スクリプトにする
    echo '- クローリングに失敗しました。kurumi-crawler実行結果を確認してください..'
fi
