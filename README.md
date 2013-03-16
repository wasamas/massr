Massr - Mini Wassr
=====

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

#### Massrを起動する
Massr実行のための環境を設定して、実行します:

```sh
$ git clone git://github.com/tdtds/massr.git
$ cd massr
$ mkdir vendor
$ bundle install --path vendor/bundle
$ export RACK_ENV=development
$ bundle exec rackup --port 9393
```

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
$ heroku addons:add memcache         # memcachedの有効化

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

Massrでは画像投稿にPicasaウェブアルバムを利用しております。

以下の設定をすることで、画像投稿機能が有効になります。

```sh
$ heroku config:add \
  PICASA_ID=XXXXXXXXXXXXXXX \
  PICASA_PASS=XXXXXXXXXXXXXXX
```

有効にすることで、Picasaウェブアルバム上に『MassrYYMMNNN』というアルバムを作成し、
そこに投稿された画像を登録します。

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

### カスタマイズする方法

public/settings.json (JSONフォーマット)に、カスタマイズ可能な項目が書かれています。これを直接書き換えても良いですし、環境変数MASSR_SETTINGSにファイル名やURLを指定することでそのファイルを使うことも可能です。MASSR_SETTINGSに指定したファイルはpublicの下に置くか、サーバサイドから参照可能なURLである必要があります(URLの場合クライアントサイドではMassr側で作成したコピーを使います)。

```sh
# ファイル(public/custom_settings.json)の場合
$ heroku congis:add MASSR_SETTINGS=custom_settings.json
```

```sh
# URLの場合
$ heroku congis:add MASSR_SETTINGS=http://exapmle.com/massr_settings.json
```

なお、MASSR_SETTINGSはMassr起動時に読み込まれるので、で指定したファイルを書き換えてもMassrを再起動するまでその内容は反映されません。


## ライセンス
Massrの著作権は「The wasam@s production」が保有しており、GPLのもとで改変・再配布が可能です。ただし、同梱する下記のプロダクトはその限りではありません。

* Twitter Bootstrap (public/cs/bootstrap*, public/js/bootstrap*)
* Lightbox JS (public/js/lightbox.js)
* jQuery URL Parser plugin (public/js/jquery.purl.js)
