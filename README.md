massr
=====

Mini Wassr

## 実行方法

### 前準備
* Twitter用開発者登録
『https://dev.twitter.com/apps/ 』でアプリ登録

call back用のURLは『http://127.0.0.1:9393/auth/twitter/callback 』(開発用)、または、『http://XXXXXXXXX/auth/twitter/callback 』(heroku用)とする。

* MongoDBをインストールしておく

```sh
$ brea insatall mongodb
```

起動は手動で。（常時稼働するサービスではないので）

```sh
$ mongod run --config /usr/local/etc/mongod.conf
```


### 開発環境(development)で実行方法
```sh
$ export RACK_ENV=development
```

```sh 
$ git clone git://github.com/tdtds/massr.git
$ cd massr
$ mkdir vendor
$ bundle install --path vendor/bundle
$ bundle exec rackup --port 9393
```

http://127.0.0.1:9393 へ接続し、動作確認

### Heroku環境(production)での実行方法
```sh 
$ git clone git://github.com/tdtds/massr.git
$ cd massr
$ mkdir vendor
$ bundle install --path vendor/bundle

# heroku コマンドのインストール（未実施のみ）
$ gem install heroku       # rvmとかrbenvな環境の人用
# or
$ sudo gem install heroku  # 上記以外
# ここまでheroku未実施のみ

# アプリ初回作成時
$ heroku apps:create massr-XXX #アプリ作成
$ heroku addons:add mongohq:free # MongoHQの有効化
## ※ MongoHQ を有効にするには Herokuにてクレジットカード登録が必要です
$ heroku config:add \
  RACK_ENV=production \
  TWITTER_CONSUMER_ID=XXXXXXXXXXXXXXX \
  TWITTER_CONSUMER_SECRET=XXXXXXXXXXXXXXX \
  TZ=Asia/Tokyo

# アプリケーションデプロイ
$ git push heroku master
$ heroku ps:scale web=1

# ログみてちゃんと動いているか確認してください
$ heroku ps
$ heroku logs -t
```
