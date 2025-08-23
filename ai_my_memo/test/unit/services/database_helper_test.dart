import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ai_my_memo/services/database_helper.dart';
import 'package:ai_my_memo/models/memo.dart';
import 'package:ai_my_memo/models/category.dart';

void main() {
  group('DatabaseHelper', () {
    late DatabaseHelper databaseHelper;

    setUpAll(() {
      // テスト用にFFIを初期化
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      databaseHelper = DatabaseHelper();
      // テスト用にメモリデータベースを使用
      await databaseHelper.deleteDatabase();
    });

    tearDown(() async {
      await databaseHelper.closeDatabase();
    });

    test('データベース初期化が正しく動作する', () async {
      final db = await databaseHelper.database;
      expect(db, isNotNull);
    });

    group('Memo CRUD操作', () {
      test('メモの作成・取得・更新・削除が正しく動作する', () async {
        final now = DateTime.now();
        
        // 作成
        final memoData = {
          'title': 'テストメモ',
          'content': 'テスト内容',
          'category_id': null,
          'is_favorite': 0,
        };
        
        final id = await databaseHelper.insertMemo(memoData);
        expect(id, greaterThan(0));

        // 取得
        final retrievedMemo = await databaseHelper.getMemoById(id);
        expect(retrievedMemo, isNotNull);
        expect(retrievedMemo!['title'], 'テストメモ');
        expect(retrievedMemo['content'], 'テスト内容');

        // 更新
        final updateData = {
          'title': '更新されたメモ',
          'content': '更新された内容',
          'is_favorite': 1,
        };
        
        final updateResult = await databaseHelper.updateMemo(id, updateData);
        expect(updateResult, 1);

        final updatedMemo = await databaseHelper.getMemoById(id);
        expect(updatedMemo!['title'], '更新されたメモ');
        expect(updatedMemo['is_favorite'], 1);

        // 削除
        final deleteResult = await databaseHelper.deleteMemo(id);
        expect(deleteResult, 1);

        final deletedMemo = await databaseHelper.getMemoById(id);
        expect(deletedMemo, isNull);
      });

      test('全メモの取得が正しく動作する', () async {
        // 複数のメモを作成
        await databaseHelper.insertMemo({
          'title': 'メモ1',
          'content': '内容1',
        });
        
        await databaseHelper.insertMemo({
          'title': 'メモ2',
          'content': '内容2',
        });

        final allMemos = await databaseHelper.getAllMemos();
        expect(allMemos.length, 2);
        expect(allMemos[0]['title'], 'メモ2'); // 新しい順
        expect(allMemos[1]['title'], 'メモ1');
      });
    });

    group('Category CRUD操作', () {
      test('カテゴリーの作成・取得・更新・削除が正しく動作する', () async {
        // 作成
        final categoryData = {
          'name': 'テストカテゴリー',
          'color': 'ff0000ff',
        };
        
        final id = await databaseHelper.insertCategory(categoryData);
        expect(id, greaterThan(0));

        // 取得
        final allCategories = await databaseHelper.getAllCategories();
        expect(allCategories.length, 1);
        expect(allCategories[0]['name'], 'テストカテゴリー');

        // 更新
        final updateData = {
          'name': '更新されたカテゴリー',
          'color': 'ff00ff00',
        };
        
        final updateResult = await databaseHelper.updateCategory(id, updateData);
        expect(updateResult, 1);

        // 削除
        final deleteResult = await databaseHelper.deleteCategory(id);
        expect(deleteResult, 1);

        final categoriesAfterDelete = await databaseHelper.getAllCategories();
        expect(categoriesAfterDelete.length, 0);
      });
    });


    group('検索機能', () {
      test('メモ検索が正しく動作する', () async {
        await databaseHelper.insertMemo({
          'title': 'Flutter開発',
          'content': 'Flutterでアプリを開発する',
        });
        
        await databaseHelper.insertMemo({
          'title': 'React学習',
          'content': 'React開発の基礎を学ぶ',
        });

        // タイトル検索
        final titleResults = await databaseHelper.searchMemos('Flutter');
        expect(titleResults.length, 1);
        expect(titleResults[0]['title'], 'Flutter開発');

        // 内容検索
        final contentResults = await databaseHelper.searchMemos('学ぶ');
        expect(contentResults.length, 1);
        expect(contentResults[0]['title'], 'React学習');

        // 部分一致検索
        final partialResults = await databaseHelper.searchMemos('開発');
        expect(partialResults.length, 2);
      });

      test('カテゴリー別メモ取得が正しく動作する', () async {
        final categoryId = await databaseHelper.insertCategory({
          'name': 'プログラミング',
        });

        await databaseHelper.insertMemo({
          'title': 'カテゴリー付きメモ',
          'content': 'テスト',
          'category_id': categoryId,
        });

        await databaseHelper.insertMemo({
          'title': 'カテゴリーなしメモ',
          'content': 'テスト',
        });

        final categoryMemos = await databaseHelper.getMemosByCategory(categoryId);
        expect(categoryMemos.length, 1);
        expect(categoryMemos[0]['title'], 'カテゴリー付きメモ');
      });

      test('お気に入りメモ取得が正しく動作する', () async {
        await databaseHelper.insertMemo({
          'title': 'お気に入りメモ',
          'content': 'テスト',
          'is_favorite': 1,
        });

        await databaseHelper.insertMemo({
          'title': '通常メモ',
          'content': 'テスト',
          'is_favorite': 0,
        });

        final favoriteMemos = await databaseHelper.getFavoriteMemos();
        expect(favoriteMemos.length, 1);
        expect(favoriteMemos[0]['title'], 'お気に入りメモ');
      });
    });
  });
}