massr
=====

Mini Wassr

## 実行方法

### 前準備
* Facebook用開発者登録
『http://www.facebook.com/developers/ 』でアプリ登録

call back用のURLは『http://127.0.0.1:9292/auth/facebook/callback 』とする。

* Twitter用開発者登録
『https://dev.twitter.com/apps/new 』でアプリ登録

call back用のURLは『http://127.0.0.1:9292/auth/twitter/callback 』とする。

### 開発環境での実行方法
```sh
$ export RACK_ENV=develop
```

```sh 
$ git clone git://github.com/tdtds/massr.gi
$ mkdir vendor
$ bundle install --path vendor/bundle
$ bundle exec shotgun
```

http://127.0.0.1:9393 へ接続し、動作確認

※『bundle exec shotgun config.ru』はなんか、認証のcollbackが失敗するので解析中
