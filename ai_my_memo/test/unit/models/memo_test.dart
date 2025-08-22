import 'package:flutter_test/flutter_test.dart';
import 'package:ai_my_memo/models/memo.dart';

void main() {
  group('Memo', () {
    late DateTime testDateTime;
    late Memo testMemo;

    setUp(() {
      testDateTime = DateTime(2025, 8, 22, 12, 0, 0);
      testMemo = Memo(
        id: 1,
        title: 'テストメモ',
        content: 'これはテスト用のメモ内容です。',
        categoryId: 1,
        isFavorite: false,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );
    });

    test('Memoインスタンスが正しく作成される', () {
      expect(testMemo.id, 1);
      expect(testMemo.title, 'テストメモ');
      expect(testMemo.content, 'これはテスト用のメモ内容です。');
      expect(testMemo.categoryId, 1);
      expect(testMemo.isFavorite, false);
      expect(testMemo.createdAt, testDateTime);
      expect(testMemo.updatedAt, testDateTime);
    });

    test('toMap()が正しいMapを返す', () {
      final map = testMemo.toMap();
      
      expect(map['id'], 1);
      expect(map['title'], 'テストメモ');
      expect(map['content'], 'これはテスト用のメモ内容です。');
      expect(map['category_id'], 1);
      expect(map['is_favorite'], 0);
      expect(map['created_at'], testDateTime.toIso8601String());
      expect(map['updated_at'], testDateTime.toIso8601String());
    });

    test('fromMap()が正しいMemoインスタンスを作成する', () {
      final map = {
        'id': 2,
        'title': 'マップからのメモ',
        'content': 'マップから作成されたメモ',
        'category_id': 2,
        'is_favorite': 1,
        'created_at': testDateTime.toIso8601String(),
        'updated_at': testDateTime.toIso8601String(),
      };

      final memo = Memo.fromMap(map);

      expect(memo.id, 2);
      expect(memo.title, 'マップからのメモ');
      expect(memo.content, 'マップから作成されたメモ');
      expect(memo.categoryId, 2);
      expect(memo.isFavorite, true);
      expect(memo.createdAt, testDateTime);
      expect(memo.updatedAt, testDateTime);
    });

    test('copyWith()が正しく動作する', () {
      final updatedMemo = testMemo.copyWith(
        title: '更新されたタイトル',
        isFavorite: true,
      );

      expect(updatedMemo.id, testMemo.id);
      expect(updatedMemo.title, '更新されたタイトル');
      expect(updatedMemo.content, testMemo.content);
      expect(updatedMemo.categoryId, testMemo.categoryId);
      expect(updatedMemo.isFavorite, true);
      expect(updatedMemo.createdAt, testMemo.createdAt);
      expect(updatedMemo.updatedAt, testMemo.updatedAt);
    });

    test('previewプロパティが正しく動作する', () {
      // 短いコンテンツのテスト
      final shortMemo = testMemo.copyWith(content: '短いメモ');
      expect(shortMemo.preview, '短いメモ');

      // 長いコンテンツのテスト
      final longContent = 'A' * 150;
      final longMemo = testMemo.copyWith(content: longContent);
      expect(longMemo.preview.length, 103); // 100文字 + '...'
      expect(longMemo.preview.endsWith('...'), true);
    });

    test('hasCategoryプロパティが正しく動作する', () {
      expect(testMemo.hasCategory, true);

      final memoWithoutCategory = testMemo.copyWith(removeCategoryId: true);
      expect(memoWithoutCategory.hasCategory, false);
    });

    test('formattedCreatedAtプロパティが正しく動作する', () {
      final now = DateTime.now();
      
      // 数分前
      final minutesAgo = now.subtract(const Duration(minutes: 5));
      final memoMinutesAgo = testMemo.copyWith(createdAt: minutesAgo);
      expect(memoMinutesAgo.formattedCreatedAt, '5分前');

      // 数時間前
      final hoursAgo = now.subtract(const Duration(hours: 2));
      final memoHoursAgo = testMemo.copyWith(createdAt: hoursAgo);
      expect(memoHoursAgo.formattedCreatedAt, '2時間前');

      // 数日前
      final daysAgo = now.subtract(const Duration(days: 3));
      final memoDaysAgo = testMemo.copyWith(createdAt: daysAgo);
      expect(memoDaysAgo.formattedCreatedAt, '3日前');

      // たった今
      final justNow = now.subtract(const Duration(seconds: 30));
      final memoJustNow = testMemo.copyWith(createdAt: justNow);
      expect(memoJustNow.formattedCreatedAt, 'たった今');
    });

    test('formattedUpdatedAtプロパティが正しく動作する', () {
      final now = DateTime.now();
      final minutesAgo = now.subtract(const Duration(minutes: 10));
      final memoUpdatedAgo = testMemo.copyWith(updatedAt: minutesAgo);
      
      expect(memoUpdatedAgo.formattedUpdatedAt, '10分前に更新');
    });

    test('等価性の比較が正しく動作する', () {
      final sameMemo = Memo(
        id: 1,
        title: 'テストメモ',
        content: 'これはテスト用のメモ内容です。',
        categoryId: 1,
        isFavorite: false,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      expect(testMemo == sameMemo, true);
      expect(testMemo.hashCode == sameMemo.hashCode, true);

      final differentMemo = testMemo.copyWith(title: '異なるタイトル');
      expect(testMemo == differentMemo, false);
    });

    test('toString()が有効な文字列を返す', () {
      final string = testMemo.toString();
      expect(string.contains('Memo{'), true);
      expect(string.contains('id: 1'), true);
      expect(string.contains('title: テストメモ'), true);
    });
  });
}