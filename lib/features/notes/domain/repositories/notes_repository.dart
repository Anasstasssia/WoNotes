import '../entities/note.dart';

abstract class NotesRepository {
  Future<List<Note>> getAllNotes();
  Future<Note?> getNoteById(String id);
  Future<void> saveNote(Note note);
  Future<void> deleteNote(String id);
  Future<List<Note>> searchNotes(String query);
}
