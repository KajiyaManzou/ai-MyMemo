import 'package:flutter/foundation.dart';
import '../models/memo.dart';
import '../services/database_helper.dart';

class MemoProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Memo> _memos = [];
  bool _isLoading = false;
  String? _error;

  List<Memo> get memos => List.unmodifiable(_memos);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMemos => _memos.isNotEmpty;
  DatabaseHelper get databaseHelper => _databaseHelper;

  Future<void> loadMemos() async {
    _setLoading(true);
    _clearError();

    try {
      final memoMaps = await _databaseHelper.getAllMemos();
      _memos = memoMaps.map((map) => Memo.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      _setError('メモの読み込みに失敗しました: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addMemo(Memo memo) async {
    try {
      final id = await _databaseHelper.insertMemo(memo.toMap());
      final newMemo = memo.copyWith(id: id);
      _memos.insert(0, newMemo);
      notifyListeners();
    } catch (e) {
      _setError('メモの作成に失敗しました: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateMemo(Memo memo) async {
    if (memo.id == null) {
      throw ArgumentError('更新するメモにIDが必要です');
    }

    try {
      await _databaseHelper.updateMemo(memo.id!, memo.toMap());
      final index = _memos.indexWhere((m) => m.id == memo.id);
      if (index != -1) {
        _memos[index] = memo;
        notifyListeners();
      }
    } catch (e) {
      _setError('メモの更新に失敗しました: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteMemo(int id) async {
    try {
      await _databaseHelper.deleteMemo(id);
      _memos.removeWhere((memo) => memo.id == id);
      notifyListeners();
    } catch (e) {
      _setError('メモの削除に失敗しました: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> toggleFavorite(int id) async {
    final index = _memos.indexWhere((memo) => memo.id == id);
    if (index == -1) return;

    final memo = _memos[index];
    final updatedMemo = memo.copyWith(
      isFavorite: !memo.isFavorite,
      updatedAt: DateTime.now(),
    );

    try {
      await _databaseHelper.updateMemo(id, updatedMemo.toMap());
      _memos[index] = updatedMemo;
      notifyListeners();
    } catch (e) {
      _setError('お気に入りの更新に失敗しました: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> searchMemos(String query) async {
    if (query.trim().isEmpty) {
      await loadMemos();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final memoMaps = await _databaseHelper.searchMemos(query.trim());
      _memos = memoMaps.map((map) => Memo.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      _setError('検索に失敗しました: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getMemosByCategory(int categoryId) async {
    _setLoading(true);
    _clearError();

    try {
      final memoMaps = await _databaseHelper.getMemosByCategory(categoryId);
      _memos = memoMaps.map((map) => Memo.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      _setError('カテゴリー別メモの取得に失敗しました: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getFavoriteMemos() async {
    _setLoading(true);
    _clearError();

    try {
      final memoMaps = await _databaseHelper.getFavoriteMemos();
      _memos = memoMaps.map((map) => Memo.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      _setError('お気に入りメモの取得に失敗しました: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Memo? getMemoById(int id) {
    try {
      return _memos.firstWhere((memo) => memo.id == id);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _databaseHelper.closeDatabase();
    super.dispose();
  }
}