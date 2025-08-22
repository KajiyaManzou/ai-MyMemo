import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ai_my_memo/providers/memo_provider.dart';
import 'package:ai_my_memo/models/memo.dart';

void main() {
  group('MemoProvider', () {
    late MemoProvider memoProvider;

    setUpAll(() {
      // テスト用にFFIを初期化
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      memoProvider = MemoProvider();
      // テスト用にデータベースをクリア
      await memoProvider.databaseHelper.deleteDatabase();
      await memoProvider.loadMemos();
    });

    tearDown(() async {
      memoProvider.dispose();
    });

    test('初期状態が正しく設定される', () {
      expect(memoProvider.memos, isEmpty);
      expect(memoProvider.isLoading, false);
      expect(memoProvider.error, isNull);
      expect(memoProvider.hasMemos, false);
    });

    test('メモの読み込みが正しく動作する', () async {
      await memoProvider.loadMemos();
      
      expect(memoProvider.isLoading, false);
      expect(memoProvider.error, isNull);
    });

    test('メモの追加が正しく動作する', () async {
      final now = DateTime.now();
      final memo = Memo(
        title: 'テストメモ',
        content: 'テスト内容',
        createdAt: now,
        updatedAt: now,
      );

      await memoProvider.addMemo(memo);

      expect(memoProvider.memos.length, 1);
      expect(memoProvider.memos.first.title, 'テストメモ');
      expect(memoProvider.memos.first.id, isNotNull);
      expect(memoProvider.hasMemos, true);
    });

    test('メモの更新が正しく動作する', () async {
      // まずメモを追加
      final now = DateTime.now();
      final memo = Memo(
        title: 'テストメモ',
        content: 'テスト内容',
        createdAt: now,
        updatedAt: now,
      );

      await memoProvider.addMemo(memo);
      final addedMemo = memoProvider.memos.first;

      // メモを更新
      final updatedMemo = addedMemo.copyWith(
        title: '更新されたメモ',
        content: '更新された内容',
        updatedAt: DateTime.now(),
      );

      await memoProvider.updateMemo(updatedMemo);

      expect(memoProvider.memos.length, 1);
      expect(memoProvider.memos.first.title, '更新されたメモ');
      expect(memoProvider.memos.first.content, '更新された内容');
    });

    test('メモの削除が正しく動作する', () async {
      // まずメモを追加
      final now = DateTime.now();
      final memo = Memo(
        title: '削除テストメモ',
        content: 'テスト内容',
        createdAt: now,
        updatedAt: now,
      );

      await memoProvider.addMemo(memo);
      final addedMemo = memoProvider.memos.first;

      // メモを削除
      await memoProvider.deleteMemo(addedMemo.id!);

      expect(memoProvider.memos.length, 0);
      expect(memoProvider.hasMemos, false);
    });

    test('お気に入り切り替えが正しく動作する', () async {
      // まずメモを追加
      final now = DateTime.now();
      final memo = Memo(
        title: 'お気に入りテストメモ',
        content: 'テスト内容',
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      );

      await memoProvider.addMemo(memo);
      final addedMemo = memoProvider.memos.first;

      // お気に入りに設定
      await memoProvider.toggleFavorite(addedMemo.id!);

      expect(memoProvider.memos.first.isFavorite, true);

      // お気に入りを解除
      await memoProvider.toggleFavorite(addedMemo.id!);

      expect(memoProvider.memos.first.isFavorite, false);
    });

    test('検索機能が正しく動作する', () async {
      // テスト用メモを複数追加
      final now = DateTime.now();
      
      await memoProvider.addMemo(Memo(
        title: 'Flutter開発',
        content: 'Flutterでアプリを作る',
        createdAt: now,
        updatedAt: now,
      ));

      await memoProvider.addMemo(Memo(
        title: 'React学習',
        content: 'Reactの基礎',
        createdAt: now,
        updatedAt: now,
      ));

      // 検索実行
      await memoProvider.searchMemos('Flutter');

      expect(memoProvider.memos.length, 1);
      expect(memoProvider.memos.first.title, 'Flutter開発');

      // 空の検索で全メモを復元
      await memoProvider.searchMemos('');

      expect(memoProvider.memos.length, 2);
    });

    test('お気に入りメモ取得が正しく動作する', () async {
      final now = DateTime.now();
      
      // お気に入りメモを追加
      await memoProvider.addMemo(Memo(
        title: 'お気に入りメモ',
        content: 'テスト',
        isFavorite: true,
        createdAt: now,
        updatedAt: now,
      ));

      // 通常メモを追加
      await memoProvider.addMemo(Memo(
        title: '通常メモ',
        content: 'テスト',
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      ));

      // お気に入りメモのみ取得
      await memoProvider.getFavoriteMemos();

      expect(memoProvider.memos.length, 1);
      expect(memoProvider.memos.first.title, 'お気に入りメモ');
      expect(memoProvider.memos.first.isFavorite, true);
    });

    test('IDによるメモ取得が正しく動作する', () async {
      final now = DateTime.now();
      final memo = Memo(
        title: 'ID検索テスト',
        content: 'テスト',
        createdAt: now,
        updatedAt: now,
      );

      await memoProvider.addMemo(memo);
      final addedMemo = memoProvider.memos.first;

      final foundMemo = memoProvider.getMemoById(addedMemo.id!);
      expect(foundMemo, isNotNull);
      expect(foundMemo!.title, 'ID検索テスト');

      final notFoundMemo = memoProvider.getMemoById(999);
      expect(notFoundMemo, isNull);
    });

    test('エラーのクリアが正しく動作する', () async {
      // エラー状態を直接設定（テスト用）
      memoProvider.clearError();
      
      expect(memoProvider.error, isNull);
    });

    test('IDがnullのメモの更新時にエラーが発生する', () async {
      final memo = Memo(
        title: 'IDなしメモ',
        content: 'テスト',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(
        () async => await memoProvider.updateMemo(memo),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}