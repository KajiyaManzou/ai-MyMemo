# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ai-MyMemoは個人用のFlutterメモアプリケーションです。シンプルで高速なメモ作成、カテゴリー分類、タグ機能、検索機能を提供します。

- 対象プラットフォーム: ios , android
- 開発言語: flutter
- エディター: cursor
- 開発環境: Xcode, Android Studio
- データベース: SQlite
- テスト: test, flutter_test
- git: コミットメッセージは日本語

## Development Commands

### Flutter Commands
```bash
# プロジェクト作成
flutter create ai_my_memo

# 依存関係のインストール
flutter pub get

# アプリの実行（デバッグモード）
flutter run

# アプリの実行（リリースモード）
flutter run --release

# ビルド（APK）
flutter build apk

# ビルド（AAB）
flutter build appbundle

# テストの実行
flutter test

# ウィジェットテストの実行
flutter test test/widget_test.dart

# 依存関係の確認
flutter pub deps

# コードの静的解析
flutter analyze

# フォーマット
dart format .
```

## Architecture

### Project Structure
```
lib/
├── main.dart                 # アプリケーションエントリーポイント
├── models/                   # データモデル
│   ├── memo.dart
│   ├── category.dart
│   └── tag.dart
├── screens/                  # 画面（Screen/Page）
│   ├── memo_list_screen.dart
│   ├── memo_edit_screen.dart
│   └── settings_screen.dart
├── widgets/                  # 再利用可能なウィジェット
│   ├── memo_item.dart
│   └── category_selector.dart
├── services/                 # ビジネスロジック・外部サービス
│   └── database_helper.dart
└── providers/               # 状態管理（Provider）
    ├── memo_provider.dart
    ├── category_provider.dart
    └── settings_provider.dart
```

### Database Schema
SQLiteを使用したローカルデータベース：

- **memos**: メモの基本情報（id, title, content, category_id, is_favorite, created_at, updated_at）
- **categories**: カテゴリー情報（id, name, color, created_at）
- **tags**: タグ情報（id, name）
- **memo_tags**: メモとタグの多対多リレーション（memo_id, tag_id）

### Key Dependencies
- `sqflite`: ローカルSQLiteデータベース
- `shared_preferences`: アプリ設定の保存
- `flutter_markdown`: マークダウン表示
- `provider`: 状態管理

### Development Phases
1. **Phase 1（2週間）**: プロジェクト初期設定、データベース、基本CRUD機能
2. **Phase 2（1週間）**: 検索機能、カテゴリー機能、タグ機能
3. **Phase 3（1週間）**: UI/UX改善、ダークモード実装
4. **Phase 4（1週間）**: お気に入り機能、設定画面、テスト、最適化

### State Management Pattern
Providerパターンを使用：
- `MemoProvider`: メモのCRUD操作
- `CategoryProvider`: カテゴリー管理
- `SettingsProvider`: アプリ設定（テーマ、フォントサイズなど）

### Key Features
- リアルタイム保存
- 全文検索
- カテゴリー・タグによるフィルタリング
- ダークモード対応
- マークダウン記法サポート