import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ai_my_memo.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createMemosTable(db);
    await _createCategoriesTable(db);
    await _createTagsTable(db);
    await _createMemoTagsTable(db);
  }

  Future<void> _createMemosTable(Database db) async {
    await db.execute('''
      CREATE TABLE memos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category_id INTEGER,
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
  }

  Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTagsTable(Database db) async {
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
  }

  Future<void> _createMemoTagsTable(Database db) async {
    await db.execute('''
      CREATE TABLE memo_tags (
        memo_id INTEGER,
        tag_id INTEGER,
        PRIMARY KEY (memo_id, tag_id),
        FOREIGN KEY (memo_id) REFERENCES memos (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');
  }

  // CRUD operations for memos
  Future<int> insertMemo(Map<String, dynamic> memo) async {
    final db = await database;
    memo['created_at'] = DateTime.now().toIso8601String();
    memo['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('memos', memo);
  }

  Future<List<Map<String, dynamic>>> getAllMemos() async {
    final db = await database;
    return await db.query(
      'memos',
      orderBy: 'updated_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getMemoById(int id) async {
    final db = await database;
    final result = await db.query(
      'memos',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateMemo(int id, Map<String, dynamic> memo) async {
    final db = await database;
    memo['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'memos',
      memo,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMemo(int id) async {
    final db = await database;
    return await db.delete(
      'memos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for categories
  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    category['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('categories', category);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query(
      'categories',
      orderBy: 'name ASC',
    );
  }

  Future<int> updateCategory(int id, Map<String, dynamic> category) async {
    final db = await database;
    return await db.update(
      'categories',
      category,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for tags
  Future<int> insertTag(Map<String, dynamic> tag) async {
    final db = await database;
    return await db.insert('tags', tag);
  }

  Future<List<Map<String, dynamic>>> getAllTags() async {
    final db = await database;
    return await db.query(
      'tags',
      orderBy: 'name ASC',
    );
  }

  Future<int> updateTag(int id, Map<String, dynamic> tag) async {
    final db = await database;
    return await db.update(
      'tags',
      tag,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTag(int id) async {
    final db = await database;
    return await db.delete(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Operations for memo_tags junction table
  Future<void> addTagToMemo(int memoId, int tagId) async {
    final db = await database;
    await db.insert(
      'memo_tags',
      {'memo_id': memoId, 'tag_id': tagId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeTagFromMemo(int memoId, int tagId) async {
    final db = await database;
    await db.delete(
      'memo_tags',
      where: 'memo_id = ? AND tag_id = ?',
      whereArgs: [memoId, tagId],
    );
  }

  Future<List<Map<String, dynamic>>> getTagsForMemo(int memoId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT t.* FROM tags t
      INNER JOIN memo_tags mt ON t.id = mt.tag_id
      WHERE mt.memo_id = ?
      ORDER BY t.name ASC
    ''', [memoId]);
  }

  Future<List<Map<String, dynamic>>> getMemosForTag(int tagId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT m.* FROM memos m
      INNER JOIN memo_tags mt ON m.id = mt.memo_id
      WHERE mt.tag_id = ?
      ORDER BY m.updated_at DESC
    ''', [tagId]);
  }

  // Search operations
  Future<List<Map<String, dynamic>>> searchMemos(String query) async {
    final db = await database;
    return await db.query(
      'memos',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getMemosByCategory(int categoryId) async {
    final db = await database;
    return await db.query(
      'memos',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'updated_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getFavoriteMemos() async {
    final db = await database;
    return await db.query(
      'memos',
      where: 'is_favorite = 1',
      orderBy: 'updated_at DESC',
    );
  }

  // Database utility methods
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'ai_my_memo.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}