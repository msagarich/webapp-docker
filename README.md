
# Multi-Project Docker Dev Environment

このリポジトリは、複数の Web開発プロジェクト（PHP/Laravel想定）を簡単に切り替えながら開発できる Docker ベースの開発環境です。  
DB（MariaDB / MySQL / PostgreSQL）なども `.env` によって柔軟に切り替えることができます。

---

## 📁 ディレクトリ構成

```
.
├── Makefile                # 各種操作コマンド
├── .env                    # 現在有効な環境設定（Makefileで切り替え）
├── env/
│   ├── pj_a.env            # プロジェクトA用の環境変数
│   ├── pj_b.env            # プロジェクトB用の環境変数
│   └── ...                 # 任意のプロジェクトごとに追加
├── projects/
│   ├── pj_a/               # Laravel プロジェクトA
│   ├── pj_b/               # Laravel プロジェクトB
│   └── ...
├── docker/
│   ├── app/                # PHP + Apache コンテナの Dockerfile
│   └── workspace/          # Composer/CLI用ワークスペース
├── .devcontainer/          # VS Code Dev Container 設定
├── compose.yml      # サービス定義
```

---

## 🚀 使い方

### プロジェクト一覧を確認

```bash
make list
```

### プロジェクトを切り替え（例：pj_a）

```bash
make switch PROJECT=pj_a
```

### 現在のプロジェクトを確認

```bash
make current
```

### 起動・停止

```bash
make up      # 起動
make down    # 停止
make restart PROJECT=pj_b  # 切り替え＋再起動
```

### DB情報を確認

```bash
make dbinfo
```

---

## 🔧 環境切り替え機能の仕組み

- `env/` フォルダ内に `.env` ファイルを用意（例：`pj_a.env`）
- `make switch PROJECT=pj_a` で `.env` をコピーし、現在の環境として有効化
- `docker-compose.yml` は `.env` から動的に以下を読み込み：
  - `PROJECT_NAME`：プロジェクト識別
  - `DB_IMAGE`：使用するDB種別（MariaDB / MySQL / PostgreSQL）
  - `DB_PORT`：ポート番号
  - `DB_VOLUME_NAME`：ボリューム名
  - `DB_VOLUME_PATH`：マウント先パス

---

## 🐳 対応DB例

| DB       | `DB_IMAGE`         | `DB_PORT` | `DB_VOLUME_PATH`               |
|----------|--------------------|-----------|--------------------------------|
| MariaDB  | mariadb:10.6       | 3306      | `/var/lib/mysql`              |
| MySQL    | mysql:8.0          | 3306      | `/var/lib/mysql`              |
| Postgres | postgres:13        | 5432      | `/var/lib/postgresql/data`    |

---

## 🧪 開発の補助ツール

- VS Code Dev Containers (`.devcontainer/`)
  - 開発者はワークスペースに自動で入れる
- Makefile コマンドで操作簡略化
- `.env` の一元管理で安全な環境切り替えを実現

---

## ✅ よく使うMakeコマンド一覧

| コマンド                      | 説明 |
|------------------------------|------|
| `make switch PROJECT=pj_x`   | プロジェクトを切り替える |
| `make current`               | 現在のプロジェクトを表示 |
| `make list`                  | 利用可能なプロジェクト一覧 |
| `make up`                    | Docker起動 |
| `make down`                  | Docker停止 |
| `make restart PROJECT=pj_x`  | プロジェクト切り替え＋再起動 |
| `make dbinfo`               | 現在のDB設定を表示 |
| `make help`                  | コマンド一覧を表示 |

---

## 📝 事前準備

- Docker & Docker Compose インストール済みであること
- Laravel プロジェクトを `projects/` 以下に配置しておくこと
- `.env` テンプレートは `env/` にプロジェクトごとに作成すること

---

## 📌 補足

- 複数プロジェクト・複数DBを同時起動する設計にはしていません（ポート競合を防ぐため）

---

## 🙌 今後の拡張アイデア

- Laravelの `.env` 自動生成 / 切り替え
- `SQLite` 対応
- データベースの初期化スクリプト対応
- テスト用DB自動展開（`make test-db` など）
