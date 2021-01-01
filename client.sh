#!/bin/sh

# 開始メッセージ
echo '- kurumi-clientを実行します..'

# +++ arguments +++
# POST用の`curl`コマンド
CURL_POST='/usr/bin/curl -H "Content-Type: application/json"'
# `kurumi-crawler`が生成したjsonの格納先
JSON_PATH=./json/
# DEBUG用のPOST先（json-server）
# URL=http://localhost:3000/withdrawals
# 本番のPOST先
URL=https://xjzv8xncp7.execute-api.ap-northeast-1.amazonaws.com/kurumi

# クローラー下の"更新日付が3日以前"のファイルを削除
echo '- 3日以前のクローリング結果ファイルを削除します..'
find ${JSON_PATH} -name "*.json" -mtime +3 -print | xargs rm;

# クローラー下の"更新日付が当日"のファイルをcurlでP0STする
echo '- POSTを実行します..'
for file in `find ${JSON_PATH} -name "*.json" -mtime 0 -print`; do
    # `curl`の標準出力は捨てる
    ${CURL_POST} ${URL} -d @${file} >/dev/null
done
echo '- POSTが終了しました..'
