import 'package:flutter_boilerplate/core/error/exceptions.dart';
import 'package:flutter_boilerplate/features/example_notes/data/dto/note_dto.dart';
import 'package:flutter_boilerplate/features/example_notes/data/notes_data_source.dart';

/// In-memory notes store seeded with a couple of examples. Data resets on app
/// restart — back it with `KeyValueStore`/a real API for persistence.
class MockNotesDataSource implements NotesDataSource {
  MockNotesDataSource() {
    final now = DateTime.now();
    _notes.addAll([
      NoteDto(
        id: '1',
        title: 'Welcome 👋',
        body: 'This is an example note. Edit or delete me.',
        updatedAt: now,
      ),
      NoteDto(
        id: '2',
        title: 'Clean architecture',
        body: 'Copy this feature folder to scaffold your own.',
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
    ]);
  }

  final List<NoteDto> _notes = [];
  var _seq = 2;

  @override
  Future<List<NoteDto>> list() async {
    await _tick();
    return List.unmodifiable(
      _notes..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
    );
  }

  @override
  Future<NoteDto> getById(String id) async {
    await _tick();
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) throw const NotFoundException('Note not found.');
    return _notes[index];
  }

  @override
  Future<NoteDto> create({required String title, required String body}) async {
    await _tick();
    final note = NoteDto(
      id: '${++_seq}',
      title: title,
      body: body,
      updatedAt: DateTime.now(),
    );
    _notes.add(note);
    return note;
  }

  @override
  Future<NoteDto> update(NoteDto note) async {
    await _tick();
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) throw const NotFoundException('Note not found.');
    final updated = NoteDto(
      id: note.id,
      title: note.title,
      body: note.body,
      updatedAt: DateTime.now(),
    );
    _notes[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _tick();
    _notes.removeWhere((n) => n.id == id);
  }

  Future<void> _tick() =>
      Future<void>.delayed(const Duration(milliseconds: 150));
}
