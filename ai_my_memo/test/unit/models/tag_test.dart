import 'package:flutter_test/flutter_test.dart';
import 'package:ai_my_memo/models/tag.dart';

void main() {
  group('Tag', () {
    late Tag testTag;

    setUp(() {
      testTag = Tag(
        id: 1,
        name: 'テストタグ',
      );
    });

    test('Tagインスタンスが正しく作成される', () {
      expect(testTag.id, 1);
      expect(testTag.name, 'テストタグ');
    });

    test('toMap()が正しいMapを返す', () {
      final map = testTag.toMap();
      
      expect(map['id'], 1);
      expect(map['name'], 'テストタグ');
    });

    test('fromMap()が正しいTagインスタンスを作成する', () {
      final map = {
        'id': 2,
        'name': 'マップからのタグ',
      };

      final tag = Tag.fromMap(map);

      expect(tag.id, 2);
      expect(tag.name, 'マップからのタグ');
    });

    test('copyWith()が正しく動作する', () {
      final updatedTag = testTag.copyWith(
        name: '更新されたタグ',
      );

      expect(updatedTag.id, testTag.id);
      expect(updatedTag.name, '更新されたタグ');
    });

    test('displayNameプロパティが正しく動作する', () {
      expect(testTag.displayName, '#テストタグ');
    });

    test('isValidプロパティが正しく動作する', () {
      expect(testTag.isValid, true);

      final emptyTag = testTag.copyWith(name: '');
      expect(emptyTag.isValid, false);

      final whitespaceTag = testTag.copyWith(name: '   ');
      expect(whitespaceTag.isValid, false);
    });

    test('isValidTagName()静的メソッドが正しく動作する', () {
      // 有効なタグ名
      expect(Tag.isValidTagName('有効なタグ'), true);
      expect(Tag.isValidTagName('validTag'), true);
      expect(Tag.isValidTagName('タグ123'), true);
      expect(Tag.isValidTagName('tag_name'), true);

      // 無効なタグ名
      expect(Tag.isValidTagName(''), false);
      expect(Tag.isValidTagName('   '), false);
      expect(Tag.isValidTagName('スペース 入り'), false);
      expect(Tag.isValidTagName('A' * 51), false); // 50文字超過

      // 特殊文字を含む無効なタグ名
      expect(Tag.isValidTagName('tag@name'), false);
      expect(Tag.isValidTagName('tag#name'), false);
      expect(Tag.isValidTagName('tag-name'), false);
    });

    test('normalizeTagName()静的メソッドが正しく動作する', () {
      expect(Tag.normalizeTagName('  TagName  '), 'tagname');
      expect(Tag.normalizeTagName('UPPERCASE'), 'uppercase');
      expect(Tag.normalizeTagName('MixedCase'), 'mixedcase');
      expect(Tag.normalizeTagName('日本語タグ'), '日本語タグ');
    });

    test('等価性の比較が正しく動作する', () {
      final sameTag = Tag(
        id: 1,
        name: 'テストタグ',
      );

      expect(testTag == sameTag, true);
      expect(testTag.hashCode == sameTag.hashCode, true);

      final differentTag = testTag.copyWith(name: '異なるタグ');
      expect(testTag == differentTag, false);
    });

    test('toString()が有効な文字列を返す', () {
      final string = testTag.toString();
      expect(string.contains('Tag{'), true);
      expect(string.contains('id: 1'), true);
      expect(string.contains('name: テストタグ'), true);
    });
  });
}