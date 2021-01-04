# はじめに

Webアプリ(主にAPIサーバー)のプロジェクト構成のスケルトンです。
src内のコードはFastAPIを利用しています。

## 使い方

### 開発

```shell
# ベースイメージのビルド
$ make build-base-image
# イメージのビルド
$ make build
# ローカルで起動
$ make run
```

上記の実行で http://0.0.0.0:80 で動きます。  
また、 http://0.0.0.0:80/docs でAPIドキュメントを参照できます。

開発中に別のコマンドを実行したいときは下記のように実行できます。

```shell
$ make run CMD='ls /app/app'                                                                                                                                                                                                                                                                  [main:fastapi-template]
docker run -it --rm --name app -p 80:80 -v $(pwd)/app:/app/app -e APP_CONFIG_FILE=local app/dev:local ls /app/app
__init__.py  constants.py          main.py      tests
config       exception_handler.py  settings.py
```

### テスト実行

```shell
$ make test
```

### 依存関係の追加

requirements.txt を更新し、下記を実行します。

```shell
$ rm requirements.lock
$ make requirements.lock
```

FastAPI自体のアプデートはベースイメージのビルドから行ってください。

## ディレクトリ構成

```shell
.
├── Dockerfile
├── Makefile
├── README.md
├── app
│   ├── __init__.py
│   ├── config
│   ├── constants.py
│   ├── exception_handler.py
│   ├── main.py
│   ├── settings.py
│   └── tests
├── baseimage
│   ├── Dockerfile
│   ├── gunicorn.conf.py
│   └── requirements.txt
├── requirements.lock
├── requirements.txt
└── requirements_test.txt
```

### app/

- アプリケーション本体です
- Dockerイメージの/app/app にマウントされます。
- エントリポイントは app.main:app です。
- テストコードは tests/ に配置します。

### baseimage/

- https://hub.docker.com/r/tiangolo/uvicorn-gunicorn-fastapi/ の更新が滞っているため自前でベースイメージを用意しています。
- 下記は tiangolo/uvicorn-gunicorn-fastapi イメージに合わせています
  - /app/app に ./app をマウントしていて、エントリポイントは app.main:app です。
  - gunicorn.conf.py の内容もこのイメージを参考に設定値をしていますが、ここでは汎用性を持たせる必要がないため設定値はべた書きです。
