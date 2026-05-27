import 'package:flutter/foundation.dart';

@immutable
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime folderDate;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.folderDate,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? folderDate,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        folderDate: folderDate ?? this.folderDate,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'folderDate': folderDate.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        folderDate: DateTime.parse(json['folderDate'] as String),
      );

  bool get isEmpty =>
      title.trim().isEmpty && content.trim().isEmpty;

  String get preview {
    final text = content.trim().replaceAll('\n', ' ');
    return text.isEmpty ? 'Нет текста' : text;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
