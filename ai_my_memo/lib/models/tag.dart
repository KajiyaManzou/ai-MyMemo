class Tag {
  final int? id;
  final String name;

  Tag({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }

  Tag copyWith({
    int? id,
    String? name,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return 'Tag{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  String get displayName => '#$name';

  bool get isValid => name.trim().isNotEmpty;

  static bool isValidTagName(String name) {
    final trimmed = name.trim();
    return trimmed.isNotEmpty && 
           trimmed.length <= 50 && 
           !trimmed.contains(' ') &&
           RegExp(r'^[a-zA-Z0-9_\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]+$').hasMatch(trimmed);
  }

  static String normalizeTagName(String name) {
    return name.trim().toLowerCase();
  }
}