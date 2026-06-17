import 'package:flutter_boilerplate/core/error/result.dart';
import 'package:flutter_boilerplate/features/example_notes/data/dto/note_dto.dart';
import 'package:flutter_boilerplate/features/example_notes/data/notes_data_source.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/note.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  const NotesRepositoryImpl(this._dataSource);

  final NotesDataSource _dataSource;

  @override
  Future<Result<List<Note>>> list() => guardAsync(() async {
        final dtos = await _dataSource.list();
        return dtos.map((d) => d.toEntity()).toList();
      });

  @override
  Future<Result<Note>> getById(String id) =>
      guardAsync(() async => (await _dataSource.getById(id)).toEntity());

  @override
  Future<Result<Note>> create({required String title, required String body}) =>
      guardAsync(() async =>
          (await _dataSource.create(title: title, body: body)).toEntity());

  @override
  Future<Result<Note>> update(Note note) => guardAsync(
        () async =>
            (await _dataSource.update(NoteDto.fromEntity(note))).toEntity(),
      );

  @override
  Future<Result<void>> delete(String id) =>
      guardAsync(() => _dataSource.delete(id));
}
