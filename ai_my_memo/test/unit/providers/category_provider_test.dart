import 'package:flutter_test/flutter_test.dart';
import 'package:ai_my_memo/providers/category_provider.dart';
import 'package:ai_my_memo/models/category.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // テスト用データベース初期化
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late CategoryProvider categoryProvider;

  setUp(() {
    categoryProvider = CategoryProvider();
  });

  tearDown(() async {
    await categoryProvider.databaseHelper.deleteDatabase();
    categoryProvider.dispose();
  });

  group('CategoryProvider初期状態テスト', () {
    test('初期状態が正しく設定されている', () {
      expect(categoryProvider.categories, isEmpty);
      expect(categoryProvider.isLoading, false);
      expect(categoryProvider.error, null);
      expect(categoryProvider.hasCategories, false);
    });
  });

  group('カテゴリー作成・編集・削除のテスト', () {
    test('カテゴリーを正常に作成できる', () async {
      final category = Category(
        name: 'テスト用カテゴリー',
        color: Colors.blue,
        createdAt: DateTime.now(),
      );

      await categoryProvider.addCategory(category);

      expect(categoryProvider.categories.length, 1);
      expect(categoryProvider.categories.first.name, 'テスト用カテゴリー');
      expect(categoryProvider.categories.first.color, Colors.blue);
      expect(categoryProvider.hasCategories, true);
    });

    test('複数のカテゴリーを作成できる', () async {
      final category1 = Category(
        name: 'カテゴリー1',
        color: Colors.red,
        createdAt: DateTime.now(),
      );
      final category2 = Category(
        name: 'カテゴリー2',
        color: Colors.green,
        createdAt: DateTime.now(),
      );

      await categoryProvider.addCategory(category1);
      await categoryProvider.addCategory(category2);

      expect(categoryProvider.categories.length, 2);
      expect(categoryProvider.categories.map((c) => c.name).toList(), 
          contains('カテゴリー1'));
      expect(categoryProvider.categories.map((c) => c.name).toList(),
          contains('カテゴリー2'));
    });

    test('カテゴリーを正常に更新できる', () async {
      final category = Category(
        name: '更新前カテゴリー',
        color: Colors.blue,
        createdAt: DateTime.now(),
      );

      await categoryProvider.addCategory(category);
      final createdCategory = categoryProvider.categories.first;

      final updatedCategory = createdCategory.copyWith(
        name: '更新後カテゴリー',
        color: Colors.red,
      );

      await categoryProvider.updateCategory(updatedCategory);

      expect(categoryProvider.categories.length, 1);
      expect(categoryProvider.categories.first.name, '更新後カテゴリー');
      expect(categoryProvider.categories.first.color, Colors.red);
    });

    test('カテゴリーを正常に削除できる', () async {
      final category = Category(
        name: '削除対象カテゴリー',
        color: Colors.blue,
        createdAt: DateTime.now(),
      );

      await categoryProvider.addCategory(category);
      expect(categoryProvider.categories.length, 1);

      final createdCategory = categoryProvider.categories.first;
      await categoryProvider.deleteCategory(createdCategory.id!);

      expect(categoryProvider.categories.length, 0);
      expect(categoryProvider.hasCategories, false);
    });

    test('重複するカテゴリー名の作成時にエラーが発生する', () async {
      final category1 = Category(
        name: '重複カテゴリー',
        color: Colors.blue,
        createdAt: DateTime.now(),
      );

      await categoryProvider.addCategory(category1);

      final category2 = Category(
        name: '重複カテゴリー',
        color: Colors.red,
        createdAt: DateTime.now(),
      );

      // 重複名での作成は例外を発生させる
      expect(() => categoryProvider.addCategory(category2), throwsA(isA<Exception>()));
    });
  });

  group('カテゴリー検索・取得のテスト', () {
    test('IDでカテゴリーを正常に取得できる', () async {
      final category = Category(
        name: 'ID検索テスト',
        color: Colors.purple,
        createdAt: DateTime.now(),
      );

      await categoryProvider.addCategory(category);
      final createdCategory = categoryProvider.categories.first;

      final foundCategory = categoryProvider.getCategoryById(createdCategory.id!);

      expect(foundCategory, isNotNull);
      expect(foundCategory!.name, 'ID検索テスト');
      expect(foundCategory.color, Colors.purple);
    });

    test('存在しないIDでの検索はnullを返す', () async {
      final foundCategory = categoryProvider.getCategoryById(999);
      expect(foundCategory, null);
    });

    test('名前でカテゴリーを正常に取得できる', () async {
      final category = Category(
        name: '名前検索テスト',
        color: Colors.orange,
        createdAt: DateTime.now(),
      );

      await categoryProvider.addCategory(category);

      final foundCategory = categoryProvider.getCategoryByName('名前検索テスト');

      expect(foundCategory, isNotNull);
      expect(foundCategory!.name, '名前検索テスト');
      expect(foundCategory.color, Colors.orange);
    });

    test('存在しない名前での検索はnullを返す', () {
      final foundCategory = categoryProvider.getCategoryByName('存在しない名前');
      expect(foundCategory, null);
    });
  });

  group('カテゴリー名重複チェック機能のテスト', () {
    test('重複チェックが正常に動作する', () async {
      final category = Category(
        name: '重複チェックテスト',
        color: Colors.teal,
        createdAt: DateTime.now(),
      );

      await categoryProvider.addCategory(category);

      expect(categoryProvider.isCategoryNameExists('重複チェックテスト'), true);
      expect(categoryProvider.isCategoryNameExists('存在しない名前'), false);
    });

    test('大文字小文字を区別しない重複チェック', () async {
      final category = Category(
        name: 'TestCategory',
        color: Colors.cyan,
        createdAt: DateTime.now(),
      );

      await categoryProvider.addCategory(category);

      expect(categoryProvider.isCategoryNameExists('TestCategory'), true);
      expect(categoryProvider.isCategoryNameExists('testcategory'), true);
      expect(categoryProvider.isCategoryNameExists('TESTCATEGORY'), true);
    });
  });

  group('エラーハンドリングのテスト', () {
    test('IDなしでの更新時にArgumentErrorが発生する', () {
      final category = Category(
        name: 'IDなしカテゴリー',
        color: Colors.brown,
        createdAt: DateTime.now(),
      );

      expect(() => categoryProvider.updateCategory(category), 
          throwsA(isA<ArgumentError>()));
    });

    test('存在しないIDでの削除時にエラーが発生しない', () async {
      // 存在しないIDでの削除は静かに失敗する（SQLiteの仕様）
      await expectLater(
        categoryProvider.deleteCategory(999), 
        completes
      );
    });
  });

  group('カテゴリー色設定のテスト', () {
    test('デフォルト色パレットが設定されている', () {
      expect(Category.defaultColors.length, 10);
      expect(Category.defaultColors, contains(Colors.blue));
      expect(Category.defaultColors, contains(Colors.red));
      expect(Category.defaultColors, contains(Colors.green));
    });

    test('色なしカテゴリーでdisplayColorがデフォルト色を返す', () {
      final category = Category(
        name: '色なしカテゴリー',
        createdAt: DateTime.now(),
      );

      expect(category.displayColor, Colors.grey);
    });

    test('色付きカテゴリーでdisplayColorが設定色を返す', () {
      final category = Category(
        name: '色付きカテゴリー',
        color: Colors.pink,
        createdAt: DateTime.now(),
      );

      expect(category.displayColor, Colors.pink);
    });
  });

  group('データ読み込み・永続化のテスト', () {
    test('loadCategories()でデータベースからカテゴリーを読み込める', () async {
      // データベースに直接カテゴリーを挿入
      final categoryData = {
        'name': 'データベーステスト',
        'color': 'ff9c27b0', // Colors.purple
        'created_at': DateTime.now().toIso8601String(),
      };

      await categoryProvider.databaseHelper.insertCategory(categoryData);

      // Providerでカテゴリーを読み込み
      await categoryProvider.loadCategories();

      expect(categoryProvider.categories.length, 1);
      expect(categoryProvider.categories.first.name, 'データベーステスト');
      expect(categoryProvider.categories.first.color, const Color(0xFF9C27B0)); // Colors.purple
    });

    test('カテゴリーが正しくデータベースに永続化される', () async {
      final category = Category(
        name: '永続化テスト',
        color: Colors.indigo,
        createdAt: DateTime.now(),
      );

      await categoryProvider.addCategory(category);

      // データベースから直接取得
      final categories = await categoryProvider.databaseHelper.getAllCategories();

      expect(categories.length, 1);
      expect(categories.first['name'], '永続化テスト');
      expect(categories.first['color'], 'ff3f51b5'); // Colors.indigo
    });
  });
}