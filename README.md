# はじめに

Webアプリ(主にAPIサーバー)のプロジェクト構成のスケルトンです。
WebフレームワークはFastAPIを利用しています。

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

下記のコマンドを実行するとテストが動きます

```shell
$ make test
```

テストでは下記を行なっています。

- black によるコードフォーマットのチェック。（[実行時のオプション](https://github.com/rhoboro/webapp_skeleton_fastapi/blob/main/pyproject.toml#L1)）
- isort によるインポート順序のチェック。（[実行時のオプション](https://github.com/rhoboro/webapp_skeleton_fastapi/blob/main/pyproject.toml#L19)）
- pytest によるユニットテストの実行。（[実行時のオプション](https://github.com/rhoboro/webapp_skeleton_fastapi/blob/main/setup.cfg#L10)）
- mypy による静的解析の実行。（[実行時のオプション](https://github.com/rhoboro/webapp_skeleton_fastapi/blob/main/setup.cfg#L1)）

フォーマットチェックでエラーになった際は、下記でコード整形を実行できます。

```shell
$ make format
```

### 依存関係の追加

直接依存しているライブラリ名（必要に応じてバージョンも）を `requirements.txt` に追加し、下記を実行します。

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
