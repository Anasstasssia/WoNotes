import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDatasource _ds;

  const NotesRepositoryImpl(this._ds);

  @override
  Future<List<Note>> getAllNotes() => _ds.getAllNotes();

  @override
  Future<Note?> getNoteById(String id) => _ds.getNoteById(id);

  @override
  Future<void> saveNote(Note note) => _ds.saveNote(note);

  @override
  Future<void> deleteNote(String id) => _ds.deleteNote(id);

  @override
  Future<List<Note>> searchNotes(String query) => _ds.searchNotes(query);
}
