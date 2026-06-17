import 'package:equatable/equatable.dart';
import 'package:flutter_boilerplate/core/error/failure.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/note.dart';

sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

final class NotesLoading extends NotesState {
  const NotesLoading();
}

final class NotesLoaded extends NotesState {
  const NotesLoaded(this.notes);
  final List<Note> notes;

  bool get isEmpty => notes.isEmpty;

  @override
  List<Object?> get props => [notes];
}

final class NotesError extends NotesState {
  const NotesError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
