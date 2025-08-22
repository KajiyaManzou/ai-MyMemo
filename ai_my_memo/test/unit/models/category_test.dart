import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_my_memo/models/category.dart';

void main() {
  group('Category', () {
    late DateTime testDateTime;
    late Category testCategory;

    setUp(() {
      testDateTime = DateTime(2025, 8, 22, 12, 0, 0);
      testCategory = Category(
        id: 1,
        name: 'テストカテゴリー',
        color: Colors.blue,
        createdAt: testDateTime,
      );
    });

    test('Categoryインスタンスが正しく作成される', () {
      expect(testCategory.id, 1);
      expect(testCategory.name, 'テストカテゴリー');
      expect(testCategory.color, Colors.blue);
      expect(testCategory.createdAt, testDateTime);
    });

    test('toMap()が正しいMapを返す', () {
      final map = testCategory.toMap();
      
      expect(map['id'], 1);
      expect(map['name'], 'テストカテゴリー');
      expect(map['color'], Colors.blue.value.toRadixString(16));
      expect(map['created_at'], testDateTime.toIso8601String());
    });

    test('色がnullの場合のtoMap()が正しく動作する', () {
      final categoryWithoutColor = Category(
        id: 2,
        name: 'カラーなしカテゴリー',
        createdAt: testDateTime,
      );

      final map = categoryWithoutColor.toMap();
      expect(map['color'], null);
    });

    test('fromMap()が正しいCategoryインスタンスを作成する', () {
      final map = {
        'id': 2,
        'name': 'マップからのカテゴリー',
        'color': 'fff44336', // Colors.red value as hex
        'created_at': testDateTime.toIso8601String(),
      };

      final category = Category.fromMap(map);

      expect(category.id, 2);
      expect(category.name, 'マップからのカテゴリー');
      expect(category.color, const Color(0xFFF44336)); // Colors.red value
      expect(category.createdAt, testDateTime);
    });

    test('色がnullの場合のfromMap()が正しく動作する', () {
      final map = {
        'id': 3,
        'name': 'カラーなしカテゴリー',
        'color': null,
        'created_at': testDateTime.toIso8601String(),
      };

      final category = Category.fromMap(map);
      expect(category.color, null);
    });

    test('copyWith()が正しく動作する', () {
      final updatedCategory = testCategory.copyWith(
        name: '更新されたカテゴリー',
        color: Colors.green,
      );

      expect(updatedCategory.id, testCategory.id);
      expect(updatedCategory.name, '更新されたカテゴリー');
      expect(updatedCategory.color, Colors.green);
      expect(updatedCategory.createdAt, testCategory.createdAt);
    });

    test('displayColorプロパティが正しく動作する', () {
      expect(testCategory.displayColor, Colors.blue);

      final categoryWithoutColor = testCategory.copyWith(removeColor: true);
      expect(categoryWithoutColor.displayColor, Colors.grey);
    });

    test('defaultColorsプロパティが適切な色のリストを返す', () {
      final colors = Category.defaultColors;
      
      expect(colors.isNotEmpty, true);
      expect(colors.contains(Colors.blue), true);
      expect(colors.contains(Colors.green), true);
      expect(colors.contains(Colors.red), true);
      expect(colors.length, 10);
    });

    test('等価性の比較が正しく動作する', () {
      final sameCategory = Category(
        id: 1,
        name: 'テストカテゴリー',
        color: Colors.blue,
        createdAt: testDateTime,
      );

      expect(testCategory == sameCategory, true);
      expect(testCategory.hashCode == sameCategory.hashCode, true);

      final differentCategory = testCategory.copyWith(name: '異なるカテゴリー');
      expect(testCategory == differentCategory, false);
    });

    test('toString()が有効な文字列を返す', () {
      final string = testCategory.toString();
      expect(string.contains('Category{'), true);
      expect(string.contains('id: 1'), true);
      expect(string.contains('name: テストカテゴリー'), true);
    });
  });
}