import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/cycle_stats.dart';
import '../providers/cycle_provider.dart';

class CycleStatsSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const CycleStatsSheet({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleProvider);
    final stats = state.stats;
    final today = DateTime.now();
    final monthLabel = DateFormatter.formatMonthDay(today);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Collapsed peek: current cycle day
          _CycleDaySummary(
            label: monthLabel,
            stats: stats,
          ),

          const SizedBox(height: 20),

          // Stats cards
          if (stats.currentCycleDay > 0) ...[
            _SectionTitle('Мои циклы'),
            const SizedBox(height: 12),
            _StatCard(
              label: 'Длина предыдущего цикла',
              value: stats.lastCycleLength != null
                  ? '${stats.lastCycleLength} дней'
                  : '—',
              tag: stats.lastCycleLength != null
                  ? _cycleTag(stats.lastCycleLength!)
                  : null,
            ),
            _StatCard(
              label: 'Длина предыдущих месячных',
              value: '${stats.averagePeriodLength.round()} дней',
              tag: _periodTag(stats.averagePeriodLength),
            ),
            _StatCard(
              label: 'Колебания длины цикла',
              value: stats.history.length >= 2
                  ? '${_minCycle(stats)}–${_maxCycle(stats)} дней'
                  : '—',
              tag: stats.regularity,
              tagColor: stats.isRegular
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ],

          const SizedBox(height: 20),

          // History
          if (stats.history.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle('История циклов'),
                Text(
                  'Все >',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final period in stats.history.take(5))
              _HistoryItem(period: period),
          ],
        ],
      ),
    );
  }

  static String _cycleTag(int len) {
    if (len >= 21 && len <= 35) return 'НОРМА';
    if (len < 21) return 'КОРОТКИЙ';
    return 'ДЛИННЫЙ';
  }

  static String _periodTag(double len) {
    if (len >= 3 && len <= 7) return 'НОРМА';
    if (len < 3) return 'КОРОТКИЙ';
    return 'ДЛИННЫЙ';
  }

  static int _minCycle(CycleStats stats) => stats.history
      .map((h) => h.length)
      .reduce((a, b) => a < b ? a : b);

  static int _maxCycle(CycleStats stats) => stats.history
      .map((h) => h.length)
      .reduce((a, b) => a > b ? a : b);
}

class _CycleDaySummary extends StatelessWidget {
  final String label;
  final CycleStats stats;

  const _CycleDaySummary({required this.label, required this.stats});

  @override
  Widget build(BuildContext context) {
    final hasData = stats.currentCycleDay > 0;
    return Text(
      hasData
          ? '$label — ${stats.currentCycleDay}-й день цикла'
          : '$label — нет данных о цикле',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall,
      );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? tag;
  final Color? tagColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.tag,
    this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          if (tag != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (tagColor ?? AppColors.success)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: tagColor ?? AppColors.success,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final CyclePeriod period;
  const _HistoryItem({required this.period});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${period.length} дней',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                period.dateRange,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          // Dot row indicating period days
          Row(
            children: List.generate(
              period.periodLength.clamp(0, 8),
              (i) => Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(left: 3),
                decoration: const BoxDecoration(
                  color: AppColors.periodFill,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
