import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/note.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/notes_repository.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/cubit/note_editor_state.dart';

class NoteEditorCubit extends Cubit<NoteEditorState> {
  NoteEditorCubit(this._repository) : super(const NoteEditorLoading());

  final NotesRepository _repository;

  Future<void> loadForEdit(String? id) async {
    if (id == null) {
      emit(const NoteEditing());
      return;
    }
    emit(const NoteEditorLoading());
    final result = await _repository.getById(id);
    emit(
      result.fold(
        (note) => NoteEditing(note: note),
        NoteEditorError.new,
      ),
    );
  }

  Future<void> save({required String title, required String body}) async {
    final existing = switch (state) {
      NoteEditing(:final note) => note,
      _ => null,
    };

    emit(const NoteSaving());
    final result = existing == null
        ? await _repository.create(title: title, body: body)
        : await _repository.update(
            existing.copyWith(title: title, body: body),
          );

    emit(result.fold((_) => const NoteSaved(), NoteEditorError.new));
  }
}
