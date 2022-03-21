# react-template
ReactのDocker開発環境テンプレート。VScodeでの開発推奨

## プロジェクト構成
以下コマンドで生成されるプロジェクトフォルダをルートに展開している。
```bash
npx create-react-app <プロジェクト名>
```

## 開発環境
### webアプリ起動
```
yarn start
```

## 本番環境
Dockerfile.prodやdocker-compose.prod.yamlを利用

## VScode設定
`.devcontainer/devcontainer.json`内に記載

## 本番環境へのデプロイ
本番環境へのデプロイは`Dockerfile.prodを用いること`
