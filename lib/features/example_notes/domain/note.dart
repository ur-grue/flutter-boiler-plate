import 'package:equatable/equatable.dart';

/// A note entity.
///
/// NOTE: `example_notes` is a REMOVABLE reference feature demonstrating the
/// full clean-architecture stack. To start clean, delete this folder plus its
/// route entries (`core/router`) and DI registrations (`core/di/injector.dart`).
class Note extends Equatable {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime updatedAt;

  Note copyWith({String? title, String? body, DateTime? updatedAt}) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, body, updatedAt];
}
