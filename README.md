massr
=====

Mini Wassr

## 実行方法

### 前準備
* Twitter用開発者登録
『https://dev.twitter.com/apps/ 』でアプリ登録

call back用のURLは『http://127.0.0.1:9292/auth/twitter/callback 』(開発用)、または、『http://XXXXXXXXX/auth/twitter/callback 』(heroku用)とする。

### 開発環境(development)での実行方法
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

※『bundle exec shotgun config.ru』はなんか、認証のcollbackが失敗するので解析中

### Heroku環境(production)での実行方法
```sh 
$ git clone git://github.com/tdtds/massr.gi
$ cd massr
$ mkdir vendor
$ bundle install --path vendor/bundle

# heroku コマンドのインストール（未実施のみ）
$ gem install heroku       # rvmとかrbenvな環境の人用
# or
$ sudo gem install heroku  # 上記以外
# ここまでheroku未実施のみ

$ heroku apps:create --stack cedar massr-<<foo>>

$ heroku config:add \
  RACK_ENV=production \
  TWITTER_CONSUMER_ID=XXXXXXXXXXXXXXX \
  TWITTER_CONSUMER_SECRET=XXXXXXXXXXXXXXX

$ git push heroku master
$ heroku ps:scale web=0 clock=1

# ログみてちゃんと動いているか確認してください
$ heroku ps
$ heroku logs -t
```
