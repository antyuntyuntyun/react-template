# react-template

React の Docker 開発環境テンプレート。VScode での開発推奨

## プロジェクト構成

以下コマンドで生成されるプロジェクトフォルダをルートに展開している。

```bash
npx create-react-app <プロジェクト名>
```

## 開発環境

### web アプリ起動

```
yarn start
```

## 本番環境

Dockerfile.prod や docker-compose.prod.yaml を利用

## VScode 設定

`.devcontainer/devcontainer.json`内に記載
