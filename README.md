Massr - Mini Wassr
=====

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)
[![Build Status](https://secure.travis-ci.org/tdtds/massr.png)](https://travis-ci.org/tdtds/massr) [![Dependency Status](https://gemnasium.com/tdtds/massr.png)](https://gemnasium.com/tdtds/massr)

## Massrについて

日本のTwitterクローン型SNSである「Wassr」が2012年9月いっぱいで閉鎖になることが発表され、Wassrのヘビーユーザーであった我々はひどく狼狽し、そして悲しくなりました。Wassrで行われていた会話を、これからどこですればいいのかと。

いくつかの選択肢を試した結果、既存のサービスでは我々の要求を満たせないことがわかりました。

ないなら作ればいい。

……というわけで作られたのがこのMassrです。Wassrの全機能を実装するわけではないので、名前もMiniですが、さらに用途も限定されているため「あなたが求めている」Wassrですらないかも知れません。Massrが目指しているのは以下のようなものです:

* シンプルな掲示板である (スレッドや話題別のコミュはいらない)
* 会員限定 (Wassrの鍵付きユーザ同士のソーシャルネットワークを想定)
* イイネがある! (最重要)

当面はHerokuの無料プランで動作することを目指しています。利用にはTwitterアカウントが必要です。

## 実行方法

### 前準備
* Twitter用開発者登録
『https://dev.twitter.com/apps/ 』でアプリ登録

call back用のURLは『http://127.0.0.1:9393/auth/twitter/callback 』(開発用)、または、『http://HOGE-FUGA.herokuapp.com/auth/twitter/callback 』(heroku用)とする。

* Googleアカウント用意[オプション]
画像のアップロードにPicasaを利用する場合、Googleアカウントが必要です。
IDとパスワードでログインするため、利用するアカウントで二段階認証を設定している場合はMassr用のパスワードの発行、そうでない場合は「安全性の低いアプリのアクセス」を有効にする必要があります。
設定は https://www.google.com/settings/security で変更できます。

* 画像投稿用Twitterアカウントの用意[オプション]
画像のアップロードにTwitterを利用する場合、Twitterアカウントが必要です。上記で用意した開発者用アカウントを流用してもかまいませんが、画像がポストされるので専用のものを用意した方がよいでしょう。また、いわゆる鍵付きアカウントにしておくと良いでしょう。

このアカウントでも同様に開発者登録をしてアプリケーションをセットアップして、Consumer keyおよびSecretに加えてAccess TokenおよびSecretの4つのキーを入手しておきます。

### 開発環境(development)で実行方法

#### MongoDBを起動する
ストレージとしてMongoDB利用しています。あらかじめインストールしておいてください(2.xが必要)。http://www.mongodb.org/downloads が参考になります。MacOSでhomebrewを使用している場合は以下:

```sh
$ brew insatall mongodb
```

Debian/Ubuntu系では以下でインストールされますが、バージョンが古い場合もあります:

```sh
$ sudo apt-get install mongodb
```

自動起動しない場合、手動で起動しておきます。例:

```sh
$ mongod run --config /usr/local/etc/mongod.conf
```

#### memcachedを起動する
処理速度のためmemcachedを利用しています。あらかじめインストールしておいてください。http://memcached.org/ からダウンロードできます。MacOSでhomebrewを使用している場合は以下:

```sh
$ brew insatall memcached
```

自動起動しない場合、手動で起動しておきます。例:

```sh
$ memcached -p 11211 -m 64m
```

#### imagemagickをインストール

CentOSなら

```sh
sudo yum -y install ImageMagick-devel
```

MacOSでhomebrewを使用している場合は以下:

```sh
$ brew install imagemagick
```

#### Massrを起動する
Massr実行のための環境を設定して、実行します:

```sh
$ git clone git://github.com/tdtds/massr.git
$ cd massr
$ mkdir vendor
$ bundle install --path vendor/bundle
$ export RACK_ENV=development
$ export EDITOR=vi
$ bundle exec puma --port 9393
```

developmentでの初回起動時にはTwitterのAPI情報、Gmailのアカウント情報を設定するようviが起動します。(上記でEDITORに指定したエディタ)
TwitterのAPI情報はユーザ認証に、Gmailのアカウント情報はメールの送信に使用します。
それぞれ ~/.pit/ 以下にファイルが作成されますので、上手く動作しないときはこの中のファイルを編集するか、一度削除して起動し直してください。

http://127.0.0.1:9393 へ接続し、動作確認します。

### Heroku環境(production)での実行方法
まず https://toolbelt.heroku.com/ から自分の環境に合った heroku toolbelt をインストールし、ログインまで済ませておきます。

```sh
$ git clone git://github.com/tdtds/massr.git
$ cd massr
$ mkdir vendor
$ bundle install --path vendor/bundle

# アプリ初回作成時
$ heroku apps:create massr-XXX #アプリ作成
$ heroku addons:add mongolab:starter # MongoLabの有効化
$ heroku addons:add sendgrid:starter # SendGridの有効化
$ heroku addons:add memcachier:dev   # memcachierの有効化

## ※ MongoLab・SendGrid を有効にするには Herokuにてクレジットカード登録が必要です
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

### 画像投稿を有効化する方法

画像投稿にPicasaウェブアルバムを利用する場合は、設定が必要です。
PicasaウェブアルバムではGoogle+と連携することで、2048px x 2048px以下の画像が容量無制限でアップロード可能となります。

yamlファイルに以下の設定をすることで、Picasaを使った画像投稿機能が有効になります:

```
"plugin": {
  "media/picasa": {
  }
}
```

また、Herokuの環境変数に以下の設定が必要です:

```sh
$ heroku config:add \
  PICASA_ID=XXXXXXXXXXXXXXX \
  PICASA_PASS=XXXXXXXXXXXXXXX
```

有効にすることで、Picasaウェブアルバム上に『MassrYYMMNNN』というアルバムを作成し、
そこに投稿された画像を登録します。

投稿される画像はデフォルトで2048px x 2048px以下になるようにリサイズされます。
投稿する画像サイズを変更する場合は後述する設定ファイルに指定して下さい。
オリジナルサイズを利用したい場合は十分に大きい値を設定する必要があります。

また、表示時に読み込まれる画像サイズはデフォルトで長辺が800pxになるように取得するようになっています。
表示する画像サイズを変更する場合も、後述する設定ファイルに指定して下さい。

画像投稿にTwitterを利用する場合は、yamlファイルに以下の設定が必要です。

```
"plugin": {
  "media/twitter": {
    "consumer_key": "aaaaaaaaaaaaaaa",
	 "access_token": "bbbbbbbbbbbbbbbbb"
  }
}
```

また、Herokuの環境変数に以下の設定が必要です:

```sh
$ heroku config:add \
  MEDIA_CONSUMER_SECRET=XXXXXXXXXXXXXXX \
  MEDIA_ACCESS_TOKEN_SECRET=XXXXXXXXXXXXXXX
```

### New Relicアドオンよるパフォーマンス計測を実施する方法

New Relicにてパフォーマンス計測等を実施する場合は以下の設定を実施することで有効になります。

※New Relicアドオンはproductionでのみ有効になります。

詳細は [New Relic | Heroku Dev Center](https://devcenter.heroku.com/articles/newrelic)をご参照ください。

#### アドオンの有効化

```sh
$ heroku addons:add newrelic:standard
$ heroku config:set NEW_RELIC_APP_NAME="XXXXXXXXXXXXXXXX" #new relicのサイトにて表示されるアプリケーション名
```

#### コンフィグファイルの修正

同梱されている config/newrelic.yml を環境に合わせ変更してください。


### mongodbデータへの修正適用方法
commit b5151ea7より、modeles/userに関して、User.statement_idsを廃止しました。
データベースへの修正を適用しなくても動作に問題有りませんが、以下のコマンドを適用し、
データベースの修正を実施することを推奨します。
データベースへの接続方法に関しては各環境をご確認ください。
（herokuの場合 heroku configコマンドで確認可能です）

```sh
$ mongo ${HOST}:${PORT}/${DBNAME} -u ${MONGO_USER} -p ${MONGO_PASS}

> db.massr.users.update({},{$unset: {statement_ids:1}},false,true)
```

## カスタマイズ
### 設定ファイル

public/default.json (JSONフォーマット)に、カスタマイズ可能な項目が書かれています。これをコピーして環境変数MASSR_SETTINGSにファイル名やURLを指定することでそのファイルを使うことも可能です。MASSR_SETTINGSに指定したファイルはpublicの下に置くか、サーバサイドから参照可能なURLである必要があります(URLの場合クライアントサイドではMassr側で作成したコピーを使います)。

```sh
# ファイル(public/settings.json)の場合
$ heroku config:add MASSR_SETTINGS=custom.json
```

```sh
# URLの場合
$ heroku config:add MASSR_SETTINGS=http://exapmle.com/massr_custom.json
```

なお、MASSR_SETTINGSはMassr起動時に読み込まれるので、で指定したファイルを書き換えてもMassrを再起動するまでその内容は反映されません。カスタマイズしたjsonファイルには、元のdefault.jsonとの差分のみ書いてあればOKです。

### Massrの設定
設定ファイルで変更できるのは、以下のとおりです:

resourceセクションの中で、Massrのアイコンを変更する設定を記述します。

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

また、icon_dirを指定しない場合、"default"が設定されます。

settingセクションの中で、Massrの動作を変更する設定を記述します。

```
"setting": {
   "upload_photo_size": 2048,
	"display_photo_size": 800
}
```

* upload_photo_size : 画像アップロード時の最大サイズ(ピクセル)
* display_photo_size: 画像表示時の最大サイズ(ピクセル)

localセクションでは、用語の変更を行えます。

```
"local": {
   (略)
}
```

この他に、後述するプラグインの設定もこのファイルで行えます。

### プラグインでカスタマイズ

いくつかのプラグインが提供されています。詳しくは[Wiki](https://github.com/tdtds/massr/wiki/Plugins)を参照して下さい。

プラグインのカスタマイズも、設定用JSONファイルに記述します。pluginセクションの中に、各プラグインの仕様に合わせて記述して下さい。

## ライセンス
Massrの著作権は「The wasam@s production」が保有しており、GPLのもとで改変・再配布が可能です。ただし、同梱する下記のプロダクトはその限りではありません。

* Twitter Bootstrap (public/cs/bootstrap*, public/js/bootstrap*)
* Magnific Popup (public/cs/magnific-popup.css, public/js/jquery.magnific-popup*)
* jQuery URL Parser plugin (public/js/jquery.purl.js)
