# claude-code-docker AI Index

このドキュメントは AI が claude-code-docker プロジェクトを理解するための index 情報です。

## プロジェクト概要

claude-code-docker は [Claude Code](https://github.com/anthropics/claude-code) を Docker コンテナ内で実行するためのプロジェクトです。Claude Code は Anthropic 社が提供する AI コーディングアシスタントで、このプロジェクトは Docker 環境で簡単に Claude Code を利用できるようにします。

## 主な機能

- Node.js 22.11.0 ベースの Docker イメージ
- @anthropic-ai/claude-code パッケージのプリインストール済み
- マルチプラットフォーム対応（linux/amd64, linux/arm64）
- **コンテナの再利用機能** - コンテナ状態を保持して継続的に利用可能
- Claude Desktop および VSCode と連携可能

## プロジェクト構造

```
claude-code-docker/
├── Dockerfile                   # Docker イメージのビルド定義
├── Implementation-Guide.ja.md   # 実装ガイド（日本語）
├── Implementation-Guide.md      # 実装ガイド（英語）
├── README.Docker.md             # Docker 関連の追加情報
├── README.ja.md                 # メインドキュメント（日本語）
├── README.md                    # メインドキュメント（英語）
├── claude-code-docker-run.sh    # コンテナ再利用用のシェルスクリプト
├── claude_desktop_config.json   # Claude Desktop 設定例
├── compose.yaml                 # Docker Compose 設定
├── package.json                 # npm パッケージ定義
├── pnpm-lock.yaml               # pnpm 依存関係ロックファイル
├── src/                         # ソースコード
│   ├── index.ts                 # エントリーポイント
│   └── types/                   # TypeScript 型定義
│       └── index.ts
└── tsconfig.json                # TypeScript 設定
```

## 主要コンポーネント

### Dockerfile

- Node.js 22.11.0 をベースに構築
- 複数のビルドステージを使用して最適化
- @anthropic-ai/claude-code をグローバルにインストール
- Git と GitHub CLI (gh) のインストール
- セキュリティ向上のため非 root ユーザー (appuser) を使用

### claude-code-docker-run.sh

コンテナの再利用を実現するためのシェルスクリプト。以下の機能を提供:

1. イメージがなければ自動的に pull
2. コンテナが存在しない場合は新規作成
3. コンテナが存在する場合は再利用（起動中なら接続、停止中なら起動）

### compose.yaml

Docker Compose 設定ファイル:
- 環境変数設定 (GITHUB_TOKEN, GITHUB_ID)
- カレントディレクトリのマウント
- インタラクティブモード設定

## 使用方法

### 推奨: シェルスクリプトを使用

```bash
chmod +x claude-code-docker-run.sh
./claude-code-docker-run.sh
```

追加オプションの指定:
```bash
./claude-code-docker-run.sh mcp serve
```

### Docker Compose を使用

```bash
# 初回起動
docker compose up

# 次回以降（コンテナ再利用）
docker compose start
```

### Docker コマンドを直接使用

```bash
# 初回起動（コンテナ作成）
docker run -it \
  --name claude-code-container \
  -e GITHUB_TOKEN \
  -w `pwd` \
  -v `pwd`:`pwd` \
  ghcr.io/gendosu/claude-code-docker:latest

# 次回以降（コンテナ再利用）
docker start -i claude-code-container
```

## Claude Desktop との連携

`claude_desktop_config.json` 設定例:

```json
{
  "mcpServers": {
    "claude-code": {
      "command": "/path/to/claude-code-docker-run.sh",
      "args": [
        "mcp",
        "serve"
      ],
      "env": {
        "NODENV_VERSION": "22.11.0",
        "GITHUB_TOKEN": "<Your GitHub Token>"
      }
    }
  }
}
```

## 技術的詳細

- **コンテナ名の固定**: コンテナを再利用するために名前を固定
- **--rm フラグの削除**: コンテナが自動的に削除されるのを防止
- **インタラクティブモード**: -it (stdin_open: true, tty: true) を使用
- **ボリュームマウント**: カレントディレクトリを同じパスでマウント
- **コンテナ状態確認**: 既に実行中かどうかを確認するロジック

## トラブルシューティング

- コンテナの削除: `docker rm claude-code-container`
- イメージの更新: 
  ```bash
  docker pull ghcr.io/gendosu/claude-code-docker:latest
  docker rm claude-code-container
  ```
- 権限問題: ボリュームマウント時の権限設定を確認

## メタデータ

- **リポジトリ**: https://github.com/gendosu/claude-code-docker
- **イメージ**: ghcr.io/gendosu/claude-code-docker:latest
- **ライセンス**: MIT
- **作者**: gendosu