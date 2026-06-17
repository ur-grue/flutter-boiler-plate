import 'package:flutter_boilerplate/features/example_notes/domain/note.dart';

/// Hand-written serialization for [Note] (no codegen).
class NoteDto {
  const NoteDto({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) => NoteDto(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  factory NoteDto.fromEntity(Note note) => NoteDto(
        id: note.id,
        title: note.title,
        body: note.body,
        updatedAt: note.updatedAt,
      );

  final String id;
  final String title;
  final String body;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'updatedAt': updatedAt.toIso8601String(),
      };

  Note toEntity() =>
      Note(id: id, title: title, body: body, updatedAt: updatedAt);
}
