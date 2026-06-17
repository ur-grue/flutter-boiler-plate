import 'package:flutter_boilerplate/features/example_notes/data/dto/note_dto.dart';

/// Low-level notes operations. Swap the mock for a real API/DB source to make
/// notes persistent across launches.
abstract interface class NotesDataSource {
  Future<List<NoteDto>> list();
  Future<NoteDto> getById(String id);
  Future<NoteDto> create({required String title, required String body});
  Future<NoteDto> update(NoteDto note);
  Future<void> delete(String id);
}
