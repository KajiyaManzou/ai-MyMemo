import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/database_helper.dart';

class CategoryProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCategories => _categories.isNotEmpty;

  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();

    try {
      final categoryMaps = await _databaseHelper.getAllCategories();
      _categories = categoryMaps.map((map) => Category.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      _setError('カテゴリーの読み込みに失敗しました: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      final id = await _databaseHelper.insertCategory(category.toMap());
      final newCategory = category.copyWith(id: id);
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      _setError('カテゴリーの作成に失敗しました: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    if (category.id == null) {
      throw ArgumentError('更新するカテゴリーにIDが必要です');
    }

    try {
      await _databaseHelper.updateCategory(category.id!, category.toMap());
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _setError('カテゴリーの更新に失敗しました: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _databaseHelper.deleteCategory(id);
      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
    } catch (e) {
      _setError('カテゴリーの削除に失敗しました: ${e.toString()}');
      rethrow;
    }
  }

  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  bool isCategoryNameExists(String name, {int? excludeId}) {
    return _categories.any((category) => 
      category.name.toLowerCase() == name.toLowerCase() && 
      category.id != excludeId
    );
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