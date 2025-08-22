import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final Color? color;
  final DateTime createdAt;

  Category({
    this.id,
    required this.name,
    this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color != null ? color!.value.toRadixString(16) : null,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] != null 
          ? Color(int.parse(map['color'] as String, radix: 16))
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Category copyWith({
    int? id,
    String? name,
    Color? color,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, color: $color, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          color == other.color &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      color.hashCode ^
      createdAt.hashCode;

  Color get displayColor => color ?? Colors.grey;

  static List<Color> get defaultColors => [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];
}