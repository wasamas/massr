Massr - Mini Wassr
=====

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)
[![Build Status](https://secure.travis-ci.org/wasamas/massr.png)](https://travis-ci.org/wasamas/massr)

## Massrについて

日本のTwitterクローン型SNSである「Wassr」が2012年9月いっぱいで閉鎖になることが発表され、Wassrのヘビーユーザーであった我々はひどく狼狽し、そして悲しくなりました。Wassrで行われていた会話を、これからどこですればいいのかと。

いくつかの選択肢を試した結果、既存のサービスでは我々の要求を満たせないことがわかりました。

ないなら作ればいい。

……というわけで作られたのがこのMassrです。Wassrの全機能を実装するわけではないので、名前もMiniですが、さらに用途も限定されているため「あなたが求めているWassr」ですらないかも知れません。Massrが目指しているのは以下のようなものです:

* シンプルな掲示板である (スレッドや話題別のコミュはいらない)
* 会員限定 (Wassrの鍵付きユーザ同士のソーシャルネットワークを想定)
* イイネがある! (最重要)

当面はHerokuの無料プランで動作することを目指しています。利用にはTwitterアカウントが必要です。

## 実行方法

### 前準備
まずログイン認証に必要なTwitter開発者登録をします。[Twitter DeveloperのApps](https://developer.twitter.com/en/apps)でTwitterアプリをひとつ登録します。Callback URLは:

* `http://localhost:9393/auth/twitter/callback` (ローカル運用 or 開発用)
* `https://EXAMPLE.herokuapp.com/auth/twitter/callback` (herokuで運用)

のように、運用するホストに対して「`/auth/twitter/callback`」を付加したものになります。

### Dockerでの実行方法
massrはDockerで動かすのが簡単です。massr本体に加えて、mongodbおよびmemcachedのコンテナが必要です。

```sh
# mongodbコンテナの起動
$ docker run -d --name mongodb -v mongodb:/data/db -p 27017:27017 mongo:3.4

# memcachedコンテナの起動
$ docker run -d --name memcached -p 11211:11211 memcached:latest

# massrコンテナの起動
# 環境変数を与えるための.envファイルを作成しておきます
$ cat .env
RACK_ENV=production
MONGODB_URI=mongodb://mongodb:27017/massr
MEMCACHE_SERVERS=memcached:11211
TWITTER_CONSUMER_ID=【YOUR TWITTER CONSUMER KEY】
TWITTER_CONSUMER_SECRET=【YOUR TWITTER SECRET KEY】

$ docker run -d -p 9393:9393 --env-file .env --link mongodb --link memcached wasamas/massr:latest
```

ブラウザで http://localhost:9393 へアクセスするとログインできるようになります。

### Herokuでの実行方法
Herokuでも簡単に運用できます。 [massrのGitHub](https://github.com/wasamas/massr)のREADMEにある「Deploy to Heroku」ボタンを押して、適当なApp nameと`TWITTER_CONSUMER_ID`および`TWITTER_CONSUMER_SECRET`を指定してDeploy appすればOKです(TwitterのCallback URLを適切に設定しておいてください)。

### 開発環境(development)での実行方法
#### MongoDBを起動する
ストレージとしてMongoDB利用しています。あらかじめインストールしておいてください(3.xが必要)。https://www.mongodb.com/download-center#community が参考になります。多くのディストリビューションで「mongodb」がパッケージ名になります。

#### memcachedを起動する
処理速度向上のためmemcachedを利用しています。あらかじめインストールしておいてください。http://memcached.org/ からダウンロードできます。多くのディストリビューションで「memcached」がパッケージ名になります。

#### imagemagickをインストール

画像投稿をする場合に、サイズ変更等のために内部でImageMagickを使っています。パッケージをインストールしておいてください。

#### Massrを起動する
Massr実行のための環境を設定して、実行します。なお実行にはrubyが必要です:

```sh
$ git clone git://github.com/wasamas/massr.git
$ cd massr
$ bundle install --path vendor/bundle
$ export RACK_ENV=development
$ export EDITOR=vi
$ bundle exec rake assets:precompile
$ bundle exec puma --port 9393
```

developmentでの初回起動時にはTwitterのAPI情報、Gmailのアカウント情報を設定するようviが起動します。(上記で`EDITOR`に指定したエディタ)
TwitterのAPI情報はユーザ認証に、Gmailのアカウント情報はメールの送信に使用します。
それぞれ ~/.pit/ 以下にファイルが作成されますので、上手く動作しないときはこの中のファイルを編集するか、一度削除して起動し直してください。

http://localhost:9393 へ接続し、動作確認します。

## カスタマイズ
### 設定ファイル

`public/default.json` (JSONフォーマット)に、カスタマイズ可能な項目が書かれています。これをコピーして環境変数`MASSR_SETTINGS`にファイル名やURLを指定することでそのファイルを使うことも可能です。`MASSR_SETTINGS`に指定したファイルは`public`の下に置くか、サーバサイドから参照可能なURLである必要があります(URLの場合クライアントサイドではMassr側で作成したコピーを使います)。

```sh
# ファイル(public/settings.json)の場合
$ heroku config:add MASSR_SETTINGS=custom.json
```

```sh
# URLの場合
$ heroku config:add MASSR_SETTINGS=http://exapmle.com/massr_custom.json
```

なお、`MASSR_SETTINGS`はMassr起動時に読み込まれるので、指定したファイルを書き換えてもMassrを再起動するまでその内容は反映されません。カスタマイズしたjsonファイルには、元のdefault.jsonとの差分のみ書いてあればOKです。

### Massrの設定
設定ファイルで変更できるのは、以下のとおりです:

`resource`セクションの中で、Massrのアイコンを変更する設定を記述します。

```
"resource": {
   "icon_dir": "default"
}
```

上記の設定をすると、以下に配置した各ファイルを参照します。

```
/public/img/icons/default/
```

現在設定可能なアイコンファイルは以下になります。

- favicon.ico
- iOSホーム画面用アイコン
	- apple-touch-icon-57x57.png
	- apple-touch-icon-72x72.png
	- apple-touch-icon-114x114.png

また、`icon_dir`を指定しない場合、"default"が設定されます。

`setting`セクションの中で、Massrの動作を変更する設定を記述します。

```
"setting": {
   "upload_photo_size": 2048,
	"display_photo_size": 800
}
```

* upload_photo_size : 画像アップロード時の最大サイズ(ピクセル)
* display_photo_size: 画像表示時の最大サイズ(ピクセル)

`local`セクションでは、用語の変更を行えます。

```
"local": {
   (略)
}
```

この他に、後述するプラグインの設定もこのファイルで行えます。

### 画像を投稿する

いくつかのサービスと連携して、massrへ画像を投稿できます。ここではTwitterを例にとって説明します。その他のサービスについては `plugins/media`の下にあるファイルを参照してください。

画像投稿用Twitterアカウントを用意します。認証用にで用意した開発者用アカウントを流用してもかまいませんが、画像がポストされるので専用のものを用意した方がよいでしょう。また、いわゆる鍵付きアカウントにしておくと良いでしょう。このアカウントでも同様に開発者登録をしてアプリケーションをセットアップし、Consumer keyおよびSecretに加えてAccess TokenおよびSecretの4つのキーを入手しておきます。

`public/default.json`に以下の設定を追加します:

```
"plugin": {
  "media/twitter": {
    "consumer_key": "aaaaaaaaaaaaaaa",
	 "access_token": "bbbbbbbbbbbbbbbbb"
  }
}
```

また、環境変数に以下の設定が必要です:

```sh
MEDIA_CONSUMER_SECRET=XXXXXXXXXXXXXXX
MEDIA_ACCESS_TOKEN_SECRET=XXXXXXXXXXXXXXX
```

### その他のプラグインでカスタマイズ

画像投稿以外にも、いくつかのプラグインが提供されています。詳しくは[Wiki](https://github.com/wasamas/massr/wiki/Plugins)を参照して下さい。

プラグインのカスタマイズも、設定用JSONファイルに記述します。`plugin`セクションの中に、各プラグインの仕様に合わせて記述して下さい。

## ライセンス
Massrの著作権は「the wasam@s production」が保有しており、GPLのもとで改変・再配布が可能です。ただし、同梱する下記のプロダクトはその限りではありません。

* Twitter Bootstrap (public/cs/bootstrap*, public/js/bootstrap*)
* Magnific Popup (public/cs/magnific-popup.css, public/js/jquery.magnific-popup*)
* jQuery URL Parser plugin (public/js/query.purl.js)
