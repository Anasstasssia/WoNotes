import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/cycle_day.dart';
import '../providers/cycle_provider.dart';

class CycleCalendarWidget extends ConsumerWidget {
  const CycleCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cycleProvider);
    final notifier = ref.read(cycleProvider.notifier);
    final marked = state.markedDays;
    final fertile = state.predictedFertile;
    final today = DateTime.now();

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: state.focusedMonth,
      locale: 'ru_RU',
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Месяц',
        CalendarFormat.twoWeeks: '2 недели',
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        titleTextStyle: AppTypography.textTheme.headlineSmall!,
        leftChevronIcon: const Icon(
          Icons.chevron_left_rounded,
          color: AppColors.textSecondary,
          size: 26,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
          size: 26,
        ),
        formatButtonDecoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        formatButtonTextStyle:
            AppTypography.textTheme.labelMedium!.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
        headerPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        formatButtonPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppTypography.textTheme.labelSmall!.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        weekendStyle: AppTypography.textTheme.labelSmall!.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        outsideTextStyle: AppTypography.textTheme.bodyMedium!.copyWith(
          color: AppColors.textTertiary,
        ),
        defaultTextStyle: AppTypography.textTheme.bodyMedium!.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        weekendTextStyle: AppTypography.textTheme.bodyMedium!.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w600,
        ),
        todayDecoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.todayRing, width: 2),
          color: Colors.transparent,
        ),
        todayTextStyle: AppTypography.textTheme.bodyMedium!.copyWith(
          color: AppColors.todayRing,
          fontWeight: FontWeight.w700,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.periodFill,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: AppTypography.textTheme.bodyMedium!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        markerDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        cellMargin: const EdgeInsets.all(4),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (ctx, day, focused) =>
            _buildDay(ctx, day, marked, fertile, today),
        outsideBuilder: (ctx, day, focused) =>
            _buildDay(ctx, day, marked, fertile, today, outside: true),
        todayBuilder: (ctx, day, focused) =>
            _buildDay(ctx, day, marked, fertile, today, isToday: true),
      ),
      onDaySelected: (selected, focused) {
        notifier.togglePeriodDay(selected);
        notifier.setFocusedMonth(focused);
      },
      onPageChanged: notifier.setFocusedMonth,
    );
  }

  Widget _buildDay(
    BuildContext ctx,
    DateTime day,
    Map<DateTime, CycleDayType> marked,
    Map<DateTime, CycleDayType> fertile,
    DateTime today, {
    bool outside = false,
    bool isToday = false,
  }) {
    final norm = DateTime(day.year, day.month, day.day);
    final markedType = marked[norm];
    final fertileType = fertile[norm];
    final isPeriod = markedType == CycleDayType.period;
    final isFertile = fertileType == CycleDayType.fertile;
    final isOvulation = fertileType == CycleDayType.ovulation;
    final isTodayDay = isSameDay(day, today);

    Color? fillColor;
    Color textColor =
        outside ? AppColors.textTertiary : AppColors.textPrimary;
    Color? borderColor;
    double borderWidth = 0;

    if (isPeriod) {
      fillColor = AppColors.periodFill;
      textColor = Colors.white;
    } else if (isOvulation) {
      fillColor = AppColors.ovulationDay.withValues(alpha: 0.2);
      borderColor = AppColors.ovulationDay;
      borderWidth = 2;
      textColor = AppColors.ovulationDay;
    } else if (isFertile) {
      fillColor = AppColors.fertileDayLight;
      textColor = AppColors.ovulationDay;
    }

    if (isTodayDay && !isPeriod) {
      borderColor = AppColors.todayRing;
      borderWidth = 2;
      if (textColor == AppColors.textPrimary) {
        textColor = AppColors.todayRing;
      }
    }

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fillColor,
          border: borderColor != null
              ? Border.all(color: borderColor, width: borderWidth)
              : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight:
                  isPeriod || isTodayDay ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
