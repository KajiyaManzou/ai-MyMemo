import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider extends ChangeNotifier {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 10;
  
  List<String> _searchHistory = [];
  
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  
  SearchProvider() {
    _loadSearchHistory();
  }
  
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_searchHistoryKey) ?? [];
      _searchHistory = history;
      notifyListeners();
    } catch (e) {
      debugPrint('検索履歴の読み込みに失敗しました: $e');
    }
  }
  
  Future<void> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    
    final trimmedQuery = query.trim();
    
    // 既存の項目を削除（重複防止）
    _searchHistory.remove(trimmedQuery);
    
    // 先頭に追加
    _searchHistory.insert(0, trimmedQuery);
    
    // 最大件数を超えた場合は末尾を削除
    if (_searchHistory.length > _maxHistoryItems) {
      _searchHistory = _searchHistory.take(_maxHistoryItems).toList();
    }
    
    await _saveSearchHistory();
    notifyListeners();
  }
  
  Future<void> removeFromSearchHistory(String query) async {
    _searchHistory.remove(query);
    await _saveSearchHistory();
    notifyListeners();
  }
  
  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
    await _saveSearchHistory();
    notifyListeners();
  }
  
  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_searchHistoryKey, _searchHistory);
    } catch (e) {
      debugPrint('検索履歴の保存に失敗しました: $e');
    }
  }
  
  List<String> getSuggestions(String query) {
    if (query.trim().isEmpty) {
      return _searchHistory;
    }
    
    return _searchHistory
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}