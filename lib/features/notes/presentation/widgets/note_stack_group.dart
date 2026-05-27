import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/note.dart';
import 'note_card.dart';

class NoteStackGroup extends StatefulWidget {
  final DateTime date;
  final List<Note> notes;
  final void Function(Note note) onNoteTap;
  final void Function(String id) onNoteDelete;

  const NoteStackGroup({
    super.key,
    required this.date,
    required this.notes,
    required this.onNoteTap,
    required this.onNoteDelete,
  });

  @override
  State<NoteStackGroup> createState() => _NoteStackGroupState();
}

class _NoteStackGroupState extends State<NoteStackGroup> {
  bool _expanded = false;

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Text(
            DateFormatter.formatDateLong(widget.date),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),

        // Stack / expanded list
        AnimatedCrossFade(
          duration: AppConstants.animNormal,
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstCurve: Curves.easeInOutCubic,
          secondCurve: Curves.easeInOutCubic,
          sizeCurve: Curves.easeInOutCubic,
          firstChild: _CollapsedStack(
            notes: widget.notes,
            onTap: _toggle,
          ),
          secondChild: _ExpandedList(
            notes: widget.notes,
            onNoteTap: widget.onNoteTap,
            onNoteDelete: widget.onNoteDelete,
            onCollapse: _toggle,
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Collapsed Stack ──────────────────────────────────────────────────────────

class _CollapsedStack extends StatelessWidget {
  final List<Note> notes;
  final VoidCallback onTap;

  const _CollapsedStack({required this.notes, required this.onTap});

  static const double _cardH = 68;
  static const double _peek = AppConstants.stackCardPeek;

  @override
  Widget build(BuildContext context) {
    final count =
        notes.length.clamp(1, AppConstants.stackMaxVisible);
    final totalH = _cardH + (count - 1) * _peek;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: totalH,
        child: Stack(
          children: [
            for (int i = count - 1; i >= 0; i--)
              Positioned(
                top: i * _peek,
                left: 0,
                right: 0,
                child: NoteCardCompact(
                  note: notes[i],
                  backgroundColor: AppColors.cardStack[i],
                  isTop: i == 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Expanded List ────────────────────────────────────────────────────────────

class _ExpandedList extends StatelessWidget {
  final List<Note> notes;
  final void Function(Note) onNoteTap;
  final void Function(String) onNoteDelete;
  final VoidCallback onCollapse;

  const _ExpandedList({
    required this.notes,
    required this.onNoteTap,
    required this.onNoteDelete,
    required this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final note in notes)
          NoteCard(
            key: ValueKey(note.id),
            note: note,
            onTap: () => onNoteTap(note),
            onDelete: () => onNoteDelete(note.id),
            slidable: true,
          ),
        // Collapse button
        GestureDetector(
          onTap: onCollapse,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 4),
                Text(
                  'Свернуть',
                  style:
                      Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
