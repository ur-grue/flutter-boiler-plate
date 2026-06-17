import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/notes_repository.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/cubit/notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._repository) : super(const NotesLoading());

  final NotesRepository _repository;

  Future<void> load() async {
    emit(const NotesLoading());
    final result = await _repository.list();
    emit(result.fold(NotesLoaded.new, NotesError.new));
  }

  Future<void> refresh() async {
    final result = await _repository.list();
    emit(result.fold(NotesLoaded.new, NotesError.new));
  }

  Future<void> delete(String id) async {
    final result = await _repository.delete(id);
    await result.fold(
      (_) => refresh(),
      (failure) async => emit(NotesError(failure)),
    );
  }
}
