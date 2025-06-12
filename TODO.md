# TODO.md

## 緊急タスク

- [ ] claude-codeのバージョンを指定したDocker buildで、指定したバージョンにならない問題
   - ビルド実行
   ```
   docker build -t gentest:1.0.11 --build-arg CLAUDE_CODE_VERSION=1.0.11 --progress=plain --no-cache .
   ```
   - バージョンの確認
   ```
   docker run --rm --entrypoint "" gentest:1.0.11 claude -v
   ```
