import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_stack_group.dart';
import '../widgets/notes_search_bar.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    final notifier = ref.read(notesProvider.notifier);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppConstants.pagePadding, 20, AppConstants.pagePadding, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ЗАМЕТКИ',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, size: 28),
                    color: AppColors.primary,
                    onPressed: () => _createNote(context, ref),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      padding: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePadding),
              child: NotesSearchBar(
                initialValue: state.searchQuery,
                onChanged: notifier.setSearch,
                onClear: notifier.clearSearch,
              ),
            ),

            const SizedBox(height: 20),

            // Content
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : state.sortedDates.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.sticky_note_2_outlined,
                          title: state.searchQuery.isEmpty
                              ? 'Нет заметок'
                              : 'Ничего не найдено',
                          subtitle: state.searchQuery.isEmpty
                              ? 'Нажмите + чтобы создать первую заметку'
                              : 'Попробуйте другой запрос',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppConstants.pagePadding,
                            0,
                            AppConstants.pagePadding,
                            100, // space for bottom nav
                          ),
                          itemCount: state.sortedDates.length,
                          itemBuilder: (ctx, i) {
                            final date = state.sortedDates[i];
                            final notes = state.groupedByDate[date]!;
                            return NoteStackGroup(
                              date: date,
                              notes: notes,
                              onNoteTap: (note) =>
                                  context.push('/note', extra: note.id),
                              onNoteDelete: (id) {
                                HapticFeedback.mediumImpact();
                                ref
                                    .read(notesProvider.notifier)
                                    .deleteNote(id);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'notes_fab',
        onPressed: () => _createNote(context, ref),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Future<void> _createNote(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final note = await ref.read(notesProvider.notifier).createNote();
    if (context.mounted) {
      context.push('/note', extra: note.id);
    }
  }
}
