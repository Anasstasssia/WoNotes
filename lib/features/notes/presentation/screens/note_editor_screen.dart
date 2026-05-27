import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String noteId;

  const NoteEditorScreen({super.key, required this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  Timer? _saveTimer;
  Note? _note;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _contentCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadNote();
    }
  }

  Future<void> _loadNote() async {
    // Note was already created by NotesScreen; fetch from provider state
    final notes = ref.read(notesProvider).notes;
    final found = notes.where((n) => n.id == widget.noteId).toList();
    if (found.isNotEmpty) {
      _note = found.first;
      _titleCtrl.text = _note!.title;
      _contentCtrl.text = _note!.content;
      setState(() {});
    }
    // Attach listeners for auto-save
    _titleCtrl.addListener(_scheduleSave);
    _contentCtrl.addListener(_scheduleSave);
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), _save);
  }

  Future<void> _save() async {
    if (_note == null) return;
    final updated = _note!.copyWith(
      title: _titleCtrl.text,
      content: _contentCtrl.text,
    );
    await ref.read(notesProvider.notifier).saveNote(updated);
    _note = updated;
  }

  Future<bool> _onWillPop() async {
    _saveTimer?.cancel();
    await _save();
    // Delete if note is empty
    if (_note != null && _note!.isEmpty) {
      await ref.read(notesProvider.notifier).deleteNote(_note!.id);
    }
    return true;
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Удалить заметку?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Отмена',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Удалить',
              style: TextStyle(color: Color(0xFFE57373)),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      _saveTimer?.cancel();
      if (_note != null) {
        await ref.read(notesProvider.notifier).deleteNote(_note!.id);
      }
      if (mounted) context.pop();
    }
  }

  void _share() {
    if (_note == null) return;
    final text = [
      if (_titleCtrl.text.isNotEmpty) _titleCtrl.text,
      if (_contentCtrl.text.isNotEmpty) _contentCtrl.text,
    ].join('\n\n');
    if (text.isNotEmpty) Share.share(text);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final note = _note;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onWillPop();
        if (context.mounted) context.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Top bar
              _TopBar(
                note: note,
                onBack: () async {
                  await _onWillPop();
                  if (context.mounted) context.pop();
                },
                onShare: _share,
                onDelete: _delete,
              ),

              // Editor
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextField(
                        controller: _titleCtrl,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          hintText: 'Заголовок',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),

                      const SizedBox(height: 4),

                      // Divider
                      Container(
                        height: 1,
                        color: AppColors.divider,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                      ),

                      // Content
                      TextField(
                        controller: _contentCtrl,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(height: 1.7),
                        decoration: const InputDecoration(
                          hintText: 'Начните писать…',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final Note? note;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _TopBar({
    required this.note,
    required this.onBack,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.textPrimary,
            onPressed: onBack,
          ),
          const Spacer(),
          if (note != null)
            Text(
              DateFormatter.formatDate(note!.createdAt),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, size: 20),
            color: AppColors.textSecondary,
            onPressed: onShare,
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, size: 22),
            color: AppColors.textSecondary,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
