import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/notes_local_datasource.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../../../core/constants/app_constants.dart';

final _notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final box = Hive.box<String>(AppConstants.notesBox);
  return NotesRepositoryImpl(NotesLocalDatasource(box));
});

// ─── State ────────────────────────────────────────────────────────────────────

class NotesState {
  final List<Note> notes;
  final bool isLoading;
  final String searchQuery;

  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.searchQuery = '',
  });

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? searchQuery,
  }) =>
      NotesState(
        notes: notes ?? this.notes,
        isLoading: isLoading ?? this.isLoading,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  List<Note> get _visible {
    if (searchQuery.trim().isEmpty) return notes;
    final q = searchQuery.toLowerCase();
    return notes
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q))
        .toList();
  }

  Map<DateTime, List<Note>> get groupedByDate {
    final map = <DateTime, List<Note>>{};
    for (final note in _visible) {
      final key = DateTime(
          note.folderDate.year, note.folderDate.month, note.folderDate.day);
      map.putIfAbsent(key, () => []).add(note);
    }
    // Sort notes within each group by updatedAt desc
    for (final key in map.keys) {
      map[key]!.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    return map;
  }

  List<DateTime> get sortedDates =>
      (groupedByDate.keys.toList()..sort((a, b) => b.compareTo(a)));
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class NotesNotifier extends StateNotifier<NotesState> {
  final NotesRepository _repo;
  static const _uuid = Uuid();

  NotesNotifier(this._repo) : super(const NotesState()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true);
    final notes = await _repo.getAllNotes();
    state = state.copyWith(notes: notes, isLoading: false);
  }

  /// Creates an empty note, persists it, and returns it.
  Future<Note> createNote() async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: '',
      content: '',
      createdAt: now,
      updatedAt: now,
      folderDate: now,
    );
    await _repo.saveNote(note);
    await loadNotes();
    return note;
  }

  Future<void> saveNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await _repo.saveNote(updated);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _repo.deleteNote(id);
    await loadNotes();
  }

  void setSearch(String q) => state = state.copyWith(searchQuery: q);
  void clearSearch() => state = state.copyWith(searchQuery: '');
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final notesProvider =
    StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  final repo = ref.watch(_notesRepositoryProvider);
  return NotesNotifier(repo);
});
