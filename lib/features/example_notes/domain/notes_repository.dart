import 'package:flutter_boilerplate/core/error/result.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/note.dart';

abstract interface class NotesRepository {
  Future<Result<List<Note>>> list();
  Future<Result<Note>> getById(String id);
  Future<Result<Note>> create({required String title, required String body});
  Future<Result<Note>> update(Note note);
  Future<Result<void>> delete(String id);
}
