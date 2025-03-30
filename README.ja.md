# claude-code-docker

Claude Code用のDockerイメージです。このイメージを使用することで、Claude Codeをコンテナ環境で実行することができます。

## 機能

- Node.js 22.11.0ベース
- @anthropic-ai/claude-codeがプリインストール済み
- マルチプラットフォーム対応（linux/amd64, linux/arm64）
- **コンテナの再利用機能**（新機能）

## 使用方法

### スクリプトを使用する方法（推奨）

1. `claude-code-docker-run.sh`スクリプトをダウンロードして実行権限を付与します：
```bash
chmod +x claude-code-docker-run.sh
```

2. スクリプトを実行：
```bash
./claude-code-docker-run.sh
```
または追加のオプションを指定：
```bash
./claude-code-docker-run.sh mcp serve
```

このスクリプトは以下の処理を行います：
- イメージが存在しない場合は自動的にプル
- コンテナが存在しない場合は新規作成
- コンテナが存在する場合は再利用（起動中なら接続、停止中なら起動）

### Docker Composeを使用する場合

1. 環境変数の設定:
```env
GITHUB_TOKEN=your_github_token
GITHUB_ID=your_github_id
```

2. コンテナの起動:
```bash
docker compose up
```

3. 次回以降は同じコンテナが再利用されます:
```bash
docker compose start
```

### Docker単体で使用する場合（手動で再利用）

初回起動（コンテナ作成）:
```bash
docker run -it \
  --name claude-code-container \
  -e GITHUB_TOKEN \
  -w `pwd` \
  -v `pwd`:`pwd` \
  ghcr.io/gendosu/claude-code-docker:latest
```

次回以降（コンテナ再利用）:
```bash
docker start -i claude-code-container
```

### Claude DesktopのMCP Serverとして使用する際の設定ファイルの例

Claude Desktopの設定ファイル（`claude_desktop_config.json`）に以下のように設定を追加することで、Claude Code機能を利用できます

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

設定項目の説明：
- `command`: 作成したスクリプトのパスを指定
- `args`: MCPサーバー起動に必要な引数を指定

注意: この設定はClaude Desktop専用です。VSCodeでは異なる設定方法が必要となります。

## GitHub Container Registry

このイメージは GitHub Container Registry で公開されています：

```bash
docker pull ghcr.io/gendosu/claude-code-docker:latest
```

## ライセンス

MIT

## 作者

gendosu
