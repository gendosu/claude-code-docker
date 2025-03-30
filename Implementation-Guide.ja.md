# Claude Code Dockerコンテナ再利用機能の実装ガイド

## 実装の概要

このプロジェクトでは、Claude Code用のDockerコンテナを再利用可能にする機能を実装しました。具体的には、以下の処理フローを実現します：

1. イメージがなければpull
2. イメージがあり、コンテナがなければコンテナを作成
3. コンテナが存在していれば、そのコンテナを起動

これにより、Docker Composeと同様のコンテナ再利用が可能になります。

## 実装方法

### 1. シェルスクリプト（claude-code-docker-run.sh）

このスクリプトは、Dockerコンテナの状態を確認し、適切なアクションを実行します：

```bash
#!/bin/bash

# コンテナ名とイメージ名の設定
CONTAINER_NAME="claude-code-container"
IMAGE_NAME="ghcr.io/gendosu/claude-code-docker:latest"

# イメージの存在チェック
if ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
  echo "イメージをプルします..."
  docker pull "$IMAGE_NAME"
fi

# コンテナの存在チェック
if docker container inspect "$CONTAINER_NAME" &> /dev/null; then
  # コンテナの状態確認
  CONTAINER_STATUS=$(docker container inspect -f '{{.State.Status}}' "$CONTAINER_NAME")
  
  if [ "$CONTAINER_STATUS" = "running" ]; then
    echo "コンテナは既に実行中です"
  else
    echo "コンテナを開始します..."
    docker start -i "$CONTAINER_NAME"
  fi
else
  # コンテナが存在しない場合、新規作成して開始
  echo "コンテナを作成して開始します..."
  docker run -it \
    --name "$CONTAINER_NAME" \
    -e GITHUB_TOKEN \
    -w "$(pwd)" \
    -v "$(pwd):$(pwd)" \
    "$IMAGE_NAME" "$@"
fi
```

### 2. Docker Compose設定（compose.yaml）

Docker Composeを使用する場合は、以下のような設定でコンテナ名を明示的に指定します：

```yaml
services:
  app:
    image: ghcr.io/gendosu/claude-code-docker:latest
    container_name: claude-code-container
    environment:
      NODE_ENV: production
      GITHUB_TOKEN: ${GITHUB_TOKEN}
      GITHUB_ID: ${GITHUB_ID}
    volumes:
      - ${PWD}:${PWD}
    working_dir: ${PWD}
    stdin_open: true  # -i に相当
    tty: true         # -t に相当
```

## 導入方法

### 方法1: シェルスクリプトを使用

1. `claude-code-docker-run.sh`スクリプトをダウンロードします
2. 実行権限を付与します：
   ```bash
   chmod +x claude-code-docker-run.sh
   ```
3. スクリプトを実行します：
   ```bash
   ./claude-code-docker-run.sh
   ```

### 方法2: Docker Composeを使用

1. `compose.yaml`ファイルを更新します
2. Docker Composeを実行します：
   ```bash
   docker compose up
   ```
3. 次回以降は同じコンテナが再利用されます：
   ```bash
   docker compose start
   ```

### 方法3: 手動でDockerコマンドを実行

初回実行時（コンテナ作成）：
```bash
docker run -it \
  --name claude-code-container \
  -e GITHUB_TOKEN \
  -w $(pwd) \
  -v $(pwd):$(pwd) \
  ghcr.io/gendosu/claude-code-docker:latest
```

2回目以降（コンテナ再利用）：
```bash
docker start -i claude-code-container
```

## 技術的な注意点

1. **コンテナ名の固定**: コンテナを再利用するために、コンテナ名を固定しています（例：`claude-code-container`）
2. **`--rm`フラグの削除**: コンテナを再利用するために、`--rm`フラグを削除しています
3. **インタラクティブモード**: `-it`（`stdin_open: true`と`tty: true`）を使用して、インタラクティブモードを維持しています
4. **ボリュームマウント**: カレントディレクトリを同じパスでマウントしています
5. **コンテナ状態の確認**: スクリプトでは、コンテナが既に実行中かどうかを確認しています

## トラブルシューティング

- **コンテナの削除**: コンテナを完全に削除する場合は `docker rm claude-code-container` を実行します
- **イメージの更新**: 新しいイメージを取得する場合は `docker pull ghcr.io/gendosu/claude-code-docker:latest` を実行し、古いコンテナを削除します
- **権限の問題**: ボリュームマウントで権限の問題が発生した場合は、適切なユーザー権限を確認してください
