import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_boilerplate/core/error/result.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/note.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/notes_repository.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/cubit/notes_cubit.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/cubit/notes_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotesRepository extends Mock implements NotesRepository {}

void main() {
  late _MockNotesRepository repo;
  final notes = [
    Note(id: '1', title: 'A', body: 'a', updatedAt: DateTime(2024)),
  ];

  setUp(() => repo = _MockNotesRepository());

  blocTest<NotesCubit, NotesState>(
    'load emits [Loading, Loaded]',
    setUp: () => when(repo.list).thenAnswer((_) async => Ok(notes)),
    build: () => NotesCubit(repo),
    act: (cubit) => cubit.load(),
    expect: () => [const NotesLoading(), NotesLoaded(notes)],
  );

  blocTest<NotesCubit, NotesState>(
    'delete refreshes the list',
    setUp: () {
      when(() => repo.delete(any())).thenAnswer((_) async => const Ok(null));
      when(repo.list).thenAnswer((_) async => const Ok(<Note>[]));
    },
    build: () => NotesCubit(repo),
    act: (cubit) => cubit.delete('1'),
    expect: () => [const NotesLoaded(<Note>[])],
  );
}
