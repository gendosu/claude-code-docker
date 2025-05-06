# claude-code-docker

Claude Code用のDockerイメージです。このイメージを使用することで、Claude Codeをコンテナ環境で実行することができます。

## 機能

- Node.js 22.11.0ベース
- @anthropic-ai/claude-codeがプリインストール済み
- マルチプラットフォーム対応（linux/amd64, linux/arm64）

## 使用方法

### Docker Composeを使用する場合

1. 環境変数の設定:
```env
GITHUB_TOKEN=your_github_token
GITHUB_ID=your_github_id
```

2. コンテナの起動:
```bash
docker compose up --build
```

### Docker単体で使用する場合

```bash
docker run --rm -it \
  -e GITHUB_TOKEN \
  -w `pwd` \
  -v `pwd`:`pwd` \
  -v claude-code-docker-node-versions:/home/appuser/.nodenv/versions \
  ghcr.io/gendosu/claude-code-docker:latest
```

### Claude DesktopのMCP Serverとして使用する際の設定ファイルの例

Claude Desktopの設定ファイル（`claude_desktop_config.json`）に以下のように設定を追加することで、Claude Code機能を利用できます

```json
{
  "mcpServers": {
    "claude-code": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e",
        "GITHUB_TOKEN",
        "-w",
        "/path/to/your/workspace",
        "-v",
        "/path/to/your/workspace:/path/to/your/workspace",
        "-v",
        "claude-code-docker-node-versions:/home/appuser/.nodenv/versions",
        "ghcr.io/gendosu/claude-code-docker:latest",
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
- `command`: Dockerコマンドを指定
- `args`: 
  - `-w`: 作業ディレクトリを指定
  - `-v`: ホストとコンテナ間のボリュームマウントを指定
  - `mcp serve`: Claude Code MCPサーバーを起動

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
