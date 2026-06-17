import 'package:equatable/equatable.dart';
import 'package:flutter_boilerplate/core/error/failure.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/note.dart';

sealed class NoteEditorState extends Equatable {
  const NoteEditorState();

  @override
  List<Object?> get props => [];
}

final class NoteEditorLoading extends NoteEditorState {
  const NoteEditorLoading();
}

/// Editing an existing note ([note] != null) or composing a new one.
final class NoteEditing extends NoteEditorState {
  const NoteEditing({this.note});
  final Note? note;

  @override
  List<Object?> get props => [note];
}

final class NoteSaving extends NoteEditorState {
  const NoteSaving();
}

final class NoteSaved extends NoteEditorState {
  const NoteSaved();
}

final class NoteEditorError extends NoteEditorState {
  const NoteEditorError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
