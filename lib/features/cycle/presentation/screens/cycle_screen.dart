import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/cycle_provider.dart';
import '../widgets/cycle_calendar_widget.dart';
import '../widgets/cycle_stats_sheet.dart';

class CycleScreen extends ConsumerWidget {
  const CycleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(cycleProvider).stats;

    return Scaffold(
      body: Stack(
        children: [
          // Calendar content
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.pagePadding,
                    20,
                    AppConstants.pagePadding,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cycle day chip
                      AnimatedSwitcher(
                        duration: AppConstants.animNormal,
                        child: stats.currentCycleDay > 0
                            ? _CycleDayChip(
                                day: stats.currentCycleDay,
                                key: ValueKey(stats.currentCycleDay),
                              )
                            : const SizedBox.shrink(),
                      ),
                      // Period legend
                      Row(
                        children: [
                          _LegendDot(
                            color: AppColors.periodFill,
                            label: 'Месячные',
                          ),
                          const SizedBox(width: 12),
                          _LegendDot(
                            color: AppColors.fertileDay,
                            label: 'Фертильные',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Calendar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const CycleCalendarWidget(),
                ),
              ],
            ),
          ),

          // Draggable stats sheet
          DraggableScrollableSheet(
            initialChildSize: 0.13,
            minChildSize: 0.13,
            maxChildSize: 0.88,
            snap: true,
            snapSizes: const [0.13, 0.88],
            builder: (ctx, scrollCtrl) => CycleStatsSheet(
              scrollController: scrollCtrl,
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleDayChip extends StatelessWidget {
  final int day;
  const _CycleDayChip({required this.day, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'День $day',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
