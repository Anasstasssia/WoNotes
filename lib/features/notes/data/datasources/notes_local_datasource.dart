import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/note.dart';

class NotesLocalDatasource {
  final Box<String> _box;

  const NotesLocalDatasource(this._box);

  Future<List<Note>> getAllNotes() async {
    final notes = <Note>[];
    for (final key in _box.keys) {
      final raw = _box.get(key as String);
      if (raw == null) continue;
      try {
        notes.add(Note.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {}
    }
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Future<Note?> getNoteById(String id) async {
    final raw = _box.get(id);
    if (raw == null) return null;
    return Note.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveNote(Note note) =>
      _box.put(note.id, jsonEncode(note.toJson()));

  Future<void> deleteNote(String id) => _box.delete(id);

  Future<List<Note>> searchNotes(String query) async {
    final q = query.toLowerCase();
    final all = await getAllNotes();
    return all
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q))
        .toList();
  }
}
