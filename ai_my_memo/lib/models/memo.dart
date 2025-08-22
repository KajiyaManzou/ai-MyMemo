class Memo {
  final int? id;
  final String title;
  final String content;
  final int? categoryId;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  Memo({
    this.id,
    required this.title,
    required this.content,
    this.categoryId,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      categoryId: map['category_id'] as int?,
      isFavorite: (map['is_favorite'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Memo copyWith({
    int? id,
    String? title,
    String? content,
    int? categoryId,
    bool removeCategoryId = false,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memo(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: removeCategoryId ? null : (categoryId ?? this.categoryId),
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Memo{id: $id, title: $title, content: $content, categoryId: $categoryId, isFavorite: $isFavorite, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Memo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          categoryId == other.categoryId &&
          isFavorite == other.isFavorite &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      categoryId.hashCode ^
      isFavorite.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  String get preview {
    if (content.length <= 100) {
      return content;
    }
    return '${content.substring(0, 100)}...';
  }

  bool get hasCategory => categoryId != null;

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }

  String get formattedUpdatedAt {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前に更新';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前に更新';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前に更新';
    } else {
      return 'たった今更新';
    }
  }
}