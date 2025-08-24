# ai-MyMemo

> シンプルで高速な個人用メモアプリ。**Cursor**と**ClaudeCode**を利用して全ての開発処理を実行を実験する。

> 初めての開発だったが、準備が足りなかった。基本設計段階から**ClaudeCode**と意見交換して内容を詰める必要があった。知らない言語で実装を依頼したので、不良があった時に人間が対策することが出来なかった。今回はフェーズ２までで開発を停止。もう一度最初からやり直す。


![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

## 📝 概要

ai-MyMemoは、日常の思考やアイデアを素早く記録・整理できるFlutter製の個人用メモアプリです。シンプルで直感的なUIと高速な動作を重視して開発されています。

## ✨ 主な機能

### 基本機能
- 📄 **メモ作成・編集・削除** - リアルタイム保存対応
- 📋 **メモ一覧表示** - 作成日時順での表示
- 🗂️ **カテゴリー管理** - メモの分類とフィルタリング
- 🔍 **全文検索** - タイトル・本文の高速検索

### 高度な機能
- ⭐ **お気に入り機能** - 重要なメモの管理
- 🌙 **ダークモード対応** - 目に優しいテーマ切り替え
- 📐 **フォントサイズ調整** - 読みやすさのカスタマイズ
- ✍️ **マークダウン記法** - リッチなテキスト表現

## 🛠️ 技術スタック

- **フレームワーク**: Flutter
- **言語**: Dart
- **データベース**: SQLite (sqflite)
- **状態管理**: Provider
- **プラットフォーム**: iOS / Android

### 主要パッケージ
- `sqflite` - ローカルデータベース
- `shared_preferences` - アプリ設定保存
- `flutter_markdown` - マークダウン表示
- `provider` - 状態管理

## 📱 スクリーンショット

_開発中のため、後日追加予定_

## 🚀 インストール・セットアップ

### 前提条件
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / Xcode

### インストール手順

1. リポジトリをクローン
```bash
git clone https://github.com/[username]/ai-MyMemo.git
cd ai-MyMemo
```

2. 依存関係をインストール
```bash
flutter pub get
```

3. アプリを実行
```bash
# デバッグモード
flutter run

# リリースモード
flutter run --release
```

## 🏗️ プロジェクト構成

```
lib/
├── main.dart                 # アプリエントリーポイント
├── models/                   # データモデル
│   ├── memo.dart
│   └── category.dart
├── screens/                  # 画面
│   ├── memo_list_screen.dart
│   ├── memo_edit_screen.dart
│   └── settings_screen.dart
├── widgets/                  # 再利用可能ウィジェット
│   ├── memo_item.dart
│   └── category_selector.dart
├── services/                 # ビジネスロジック
│   └── database_helper.dart
└── providers/               # 状態管理
    ├── memo_provider.dart
    ├── category_provider.dart
    └── search_provider.dart
```

## 🗄️ データベース設計

- **memos**: メモの基本情報
- **categories**: カテゴリー管理

詳細は[ER図](database_er_diagram.md)を参照してください。

## 🚧 開発ロードマップ

- [x] **Phase 1**: プロジェクト初期設定・基本CRUD機能
- [x] **Phase 2**: 検索・分類機能
- [ ] **Phase 3**: UI/UX改善・ダークモード
- [ ] **Phase 4**: 追加機能・テスト・最適化

詳細なタスクは[TASK.md](TASK.md)を参照してください。

## 🎯 パフォーマンス目標

- ⚡ アプリ起動速度: 2秒以内
- 📝 メモ作成から保存: 10秒以内
- 🔒 データの安全性: バックアップ機能

## 🔮 将来の拡張予定

- 🏷️ **タグ機能** - 柔軟なタグ付けと検索
- ☁️ クラウド同期機能
- 🎤 音声メモ機能
- 🖼️ 画像添付機能
- 📄 エクスポート機能（PDF、テキスト）
- 🧩 ウィジェット対応

## 🧪 テスト

```bash
# 全テスト実行
flutter test

# ウィジェットテスト
flutter test test/widget_test.dart

# コード解析
flutter analyze

# フォーマット
dart format .
```

## 🤝 コントリビューション

このプロジェクトは個人開発ですが、提案やフィードバックは歓迎します。

## 📄 ライセンス

MIT License

## 📞 お問い合わせ

プロジェクトに関する質問や提案がありましたら、Issueを作成してください。

---

<div align="center">
Made with ❤️ using Flutter
</div>