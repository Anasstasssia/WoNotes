import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool slidable;

  const NoteCard({
    super.key,
    required this.note,
    this.backgroundColor,
    this.onTap,
    this.onDelete,
    this.slidable = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = _buildCard(context);
    if (!slidable || onDelete == null) return card;

    return Slidable(
      key: ValueKey(note.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.22,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: Colors.transparent,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE57373),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
      child: card,
    );
  }

  Widget _buildCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title.isEmpty ? 'Без названия' : note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: note.title.isEmpty
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (note.content.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        note.preview,
                        style:
                            Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                DateFormatter.formatTime(note.createdAt),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact stacked-view card — no content preview, used in the collapsed stack.
class NoteCardCompact extends StatelessWidget {
  final Note note;
  final Color backgroundColor;
  final bool isTop;

  const NoteCardCompact({
    super.key,
    required this.note,
    required this.backgroundColor,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: AppColors.shadowStrong,
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: isTop
          ? Row(
              children: [
                Expanded(
                  child: Text(
                    note.title.isEmpty ? 'Без названия' : note.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormatter.formatTime(note.createdAt),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            )
          : null,
    );
  }
}
