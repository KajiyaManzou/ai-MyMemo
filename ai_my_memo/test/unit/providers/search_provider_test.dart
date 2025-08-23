import 'package:flutter_test/flutter_test.dart';
import 'package:ai_my_memo/providers/search_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SearchProvider searchProvider;

  setUp(() async {
    // SharedPreferencesのモックを設定
    SharedPreferences.setMockInitialValues({});
    searchProvider = SearchProvider();
    // 初期化完了まで少し待機
    await Future.delayed(const Duration(milliseconds: 50));
  });

  tearDown(() {
    searchProvider.dispose();
  });

  group('SearchProvider初期状態テスト', () {
    test('初期状態が正しく設定されている', () {
      expect(searchProvider.searchHistory, isEmpty);
      expect(searchProvider.getSuggestions(''), isEmpty);
    });
  });

  group('検索履歴管理テスト', () {
    test('検索履歴を正常に追加できる', () async {
      await searchProvider.addToSearchHistory('Flutter');

      expect(searchProvider.searchHistory.length, 1);
      expect(searchProvider.searchHistory.first, 'Flutter');
    });

    test('複数の検索履歴を追加できる', () async {
      await searchProvider.addToSearchHistory('Flutter');
      await searchProvider.addToSearchHistory('Dart');
      await searchProvider.addToSearchHistory('Mobile Development');

      expect(searchProvider.searchHistory.length, 3);
      expect(searchProvider.searchHistory.first, 'Mobile Development'); // 最新
      expect(searchProvider.searchHistory, contains('Flutter'));
      expect(searchProvider.searchHistory, contains('Dart'));
    });

    test('重複する検索履歴は最新位置に移動する', () async {
      await searchProvider.addToSearchHistory('Flutter');
      await searchProvider.addToSearchHistory('Dart');
      await searchProvider.addToSearchHistory('Flutter'); // 重複

      expect(searchProvider.searchHistory.length, 2);
      expect(searchProvider.searchHistory.first, 'Flutter'); // 最新位置
      expect(searchProvider.searchHistory.last, 'Dart');
    });

    test('最大10件の履歴制限が機能する', () async {
      // 12件の履歴を追加
      for (int i = 1; i <= 12; i++) {
        await searchProvider.addToSearchHistory('検索$i');
      }

      expect(searchProvider.searchHistory.length, 10);
      expect(searchProvider.searchHistory.first, '検索12'); // 最新
      expect(searchProvider.searchHistory.last, '検索3'); // 古い2件は削除される
      expect(searchProvider.searchHistory, isNot(contains('検索1')));
      expect(searchProvider.searchHistory, isNot(contains('検索2')));
    });

    test('空文字や空白のみの履歴は追加されない', () async {
      await searchProvider.addToSearchHistory('');
      await searchProvider.addToSearchHistory('   ');
      await searchProvider.addToSearchHistory('\t\n');

      expect(searchProvider.searchHistory, isEmpty);
    });

    test('文字列がトリムされて保存される', () async {
      await searchProvider.addToSearchHistory('  Flutter  ');

      expect(searchProvider.searchHistory.length, 1);
      expect(searchProvider.searchHistory.first, 'Flutter');
    });
  });

  group('検索履歴削除テスト', () {
    test('個別の検索履歴を削除できる', () async {
      await searchProvider.addToSearchHistory('Flutter');
      await searchProvider.addToSearchHistory('Dart');
      await searchProvider.addToSearchHistory('Widget');

      await searchProvider.removeFromSearchHistory('Dart');

      expect(searchProvider.searchHistory.length, 2);
      expect(searchProvider.searchHistory, contains('Flutter'));
      expect(searchProvider.searchHistory, contains('Widget'));
      expect(searchProvider.searchHistory, isNot(contains('Dart')));
    });

    test('存在しない履歴の削除は何も起こらない', () async {
      await searchProvider.addToSearchHistory('Flutter');

      await searchProvider.removeFromSearchHistory('存在しない履歴');

      expect(searchProvider.searchHistory.length, 1);
      expect(searchProvider.searchHistory.first, 'Flutter');
    });

    test('全ての検索履歴を一括クリアできる', () async {
      await searchProvider.addToSearchHistory('Flutter');
      await searchProvider.addToSearchHistory('Dart');
      await searchProvider.addToSearchHistory('Widget');

      await searchProvider.clearSearchHistory();

      expect(searchProvider.searchHistory, isEmpty);
    });
  });

  group('検索候補・フィルタリングテスト', () {
    test('部分一致での候補が正常に取得される', () async {
      await searchProvider.addToSearchHistory('Flutter開発');
      await searchProvider.addToSearchHistory('Flutterアプリ');
      await searchProvider.addToSearchHistory('Dart言語');
      await searchProvider.addToSearchHistory('React開発');

      final suggestions = searchProvider.getSuggestions('Flutter');

      expect(suggestions.length, 2);
      expect(suggestions, contains('Flutter開発'));
      expect(suggestions, contains('Flutterアプリ'));
      expect(suggestions, isNot(contains('Dart言語')));
      expect(suggestions, isNot(contains('React開発')));
    });

    test('大文字小文字を区別しない候補検索', () async {
      await searchProvider.addToSearchHistory('Flutter開発');
      await searchProvider.addToSearchHistory('FLUTTER学習');
      await searchProvider.addToSearchHistory('flutter入門');

      final suggestions = searchProvider.getSuggestions('flutter');

      expect(suggestions.length, 3);
      expect(suggestions, contains('Flutter開発'));
      expect(suggestions, contains('FLUTTER学習'));
      expect(suggestions, contains('flutter入門'));
    });

    test('空文字での候補取得は全履歴を返す', () async {
      await searchProvider.addToSearchHistory('Flutter');
      await searchProvider.addToSearchHistory('Dart');
      await searchProvider.addToSearchHistory('Widget');

      final suggestions = searchProvider.getSuggestions('');

      expect(suggestions.length, 3);
      expect(suggestions, contains('Flutter'));
      expect(suggestions, contains('Dart'));
      expect(suggestions, contains('Widget'));
    });

    test('マッチしない検索文字列では空のリストを返す', () async {
      await searchProvider.addToSearchHistory('Flutter');
      await searchProvider.addToSearchHistory('Dart');

      final suggestions = searchProvider.getSuggestions('Java');

      expect(suggestions, isEmpty);
    });

    test('候補は追加順（新しい順）で返される', () async {
      await searchProvider.addToSearchHistory('Flutter基礎');
      await searchProvider.addToSearchHistory('Flutter応用');
      await searchProvider.addToSearchHistory('Flutter上級');

      final suggestions = searchProvider.getSuggestions('Flutter');

      expect(suggestions.length, 3);
      expect(suggestions[0], 'Flutter上級'); // 最新
      expect(suggestions[1], 'Flutter応用');
      expect(suggestions[2], 'Flutter基礎'); // 最古
    });
  });

  group('データ永続化テスト', () {
    test('検索履歴がSharedPreferencesに保存される', () async {
      await searchProvider.addToSearchHistory('保存テスト');

      // 新しいインスタンスで履歴を読み込み
      final newSearchProvider = SearchProvider();
      await Future.delayed(const Duration(milliseconds: 50)); // 初期化待機

      expect(newSearchProvider.searchHistory.length, 1);
      expect(newSearchProvider.searchHistory.first, '保存テスト');

      newSearchProvider.dispose();
    });

    test('検索履歴削除がSharedPreferencesに反映される', () async {
      await searchProvider.addToSearchHistory('削除前テスト');
      await searchProvider.clearSearchHistory();

      // 新しいインスタンスで履歴を読み込み
      final newSearchProvider = SearchProvider();
      await Future.delayed(const Duration(milliseconds: 50)); // 初期化待機

      expect(newSearchProvider.searchHistory, isEmpty);

      newSearchProvider.dispose();
    });
  });

  group('エラーハンドリング・エッジケーステスト', () {
    test('特殊文字を含む検索文字列の処理', () async {
      const specialString = 'Flutter & Dart: 100% @awesome #mobile \$dev! 🚀';
      
      await searchProvider.addToSearchHistory(specialString);

      expect(searchProvider.searchHistory.length, 1);
      expect(searchProvider.searchHistory.first, specialString);

      final suggestions = searchProvider.getSuggestions('Flutter');
      expect(suggestions, contains(specialString));
    });

    test('Unicode絵文字を含む検索文字列の処理', () async {
      const emojiString = 'Flutter 🚀 開発日記 📱✨';
      
      await searchProvider.addToSearchHistory(emojiString);

      expect(searchProvider.searchHistory.length, 1);
      expect(searchProvider.searchHistory.first, emojiString);

      final suggestions = searchProvider.getSuggestions('Flutter');
      expect(suggestions, contains(emojiString));
    });

    test('dispose()メソッドが正常に実行される', () async {
      // SearchProviderが正常にdisposeできることを確認
      // （SearchProviderの内部でChangeNotifierのdisposeを呼ぶ）
      final testProvider = SearchProvider();
      await Future.delayed(const Duration(milliseconds: 10)); // 初期化待機
      
      // 正常にdisposeできることを確認（例外が発生しない）
      testProvider.dispose();
      
      // テスト完了 - 特に断言は不要（例外が発生しなければ成功）
    });
  });
}