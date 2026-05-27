import '../entities/cycle_day.dart';
import '../entities/cycle_stats.dart';

class CycleCalculator {
  const CycleCalculator._();

  static CycleStats calculate(List<CycleDay> days) {
    final periodDays = days
        .where((d) => d.type == CycleDayType.period)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (periodDays.isEmpty) return CycleStats.empty;

    final groups = _groupPeriods(periodDays);
    if (groups.isEmpty) return CycleStats.empty;

    // Cycle lengths between consecutive period starts
    final cycleLengths = <int>[];
    for (int i = 1; i < groups.length; i++) {
      final len =
          groups[i].first.difference(groups[i - 1].first).inDays;
      if (len > 15 && len < 90) cycleLengths.add(len);
    }

    final avgCycle = cycleLengths.isEmpty
        ? 28.0
        : cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;

    final periodLengths = groups.map((g) => g.length).toList();
    final avgPeriod = periodLengths.isEmpty
        ? 5.0
        : periodLengths.reduce((a, b) => a + b) / periodLengths.length;

    // Regularity
    String regularity = 'Нет данных';
    bool isRegular = true;
    if (cycleLengths.length >= 2) {
      final spread = cycleLengths.reduce((a, b) => a > b ? a : b) -
          cycleLengths.reduce((a, b) => a < b ? a : b);
      if (spread <= 7) {
        regularity = 'Регулярный';
        isRegular = true;
      } else if (spread <= 14) {
        regularity = 'Нерегулярный';
        isRegular = false;
      } else {
        regularity = 'Очень нерегулярный';
        isRegular = false;
      }
    } else if (cycleLengths.length == 1) {
      regularity = 'Мало данных';
    }

    // Current cycle day
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime? cycleStart;
    int currentDay = 0;
    for (final group in groups.reversed) {
      if (!group.first.isAfter(today)) {
        cycleStart = group.first;
        currentDay = today.difference(group.first).inDays + 1;
        break;
      }
    }

    // History (most recent first)
    final history = <CyclePeriod>[];
    for (int i = 0; i < groups.length; i++) {
      final start = groups[i].first;
      final end = i < groups.length - 1
          ? groups[i + 1].first.subtract(const Duration(days: 1))
          : start.add(Duration(days: avgCycle.round() - 1));
      final len = end.difference(start).inDays + 1;
      history.add(CyclePeriod(
        startDate: start,
        endDate: end,
        length: len,
        periodLength: groups[i].length,
      ));
    }
    history.sort((a, b) => b.startDate.compareTo(a.startDate));

    return CycleStats(
      currentCycleDay: currentDay,
      averageCycleLength: avgCycle,
      averagePeriodLength: avgPeriod,
      isRegular: isRegular,
      regularity: regularity,
      cycleStartDate: cycleStart,
      lastCycleLength:
          cycleLengths.isNotEmpty ? cycleLengths.last : null,
      history: history,
    );
  }

  /// Returns a map of date → type for the predicted fertile window
  /// based on the last cycle start.
  static Map<DateTime, CycleDayType> fertileWindow(
    List<CycleDay> days,
    double avgCycleLength,
  ) {
    final periodDays = days
        .where((d) => d.type == CycleDayType.period)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (periodDays.isEmpty) return {};
    final groups = _groupPeriods(periodDays);
    if (groups.isEmpty) return {};

    final lastStart = groups.last.first;
    final ovulation =
        lastStart.add(Duration(days: avgCycleLength.round() - 14));

    final window = <DateTime, CycleDayType>{};
    for (int i = -5; i <= 0; i++) {
      final d = ovulation.add(Duration(days: i));
      window[d] = i == 0 ? CycleDayType.ovulation : CycleDayType.fertile;
    }
    return window;
  }

  static List<List<DateTime>> _groupPeriods(List<CycleDay> sorted) {
    if (sorted.isEmpty) return [];
    final groups = <List<DateTime>>[];
    var current = [sorted.first.date];
    for (int i = 1; i < sorted.length; i++) {
      final gap =
          sorted[i].date.difference(sorted[i - 1].date).inDays;
      if (gap <= 2) {
        current.add(sorted[i].date);
      } else {
        groups.add(current);
        current = [sorted[i].date];
      }
    }
    groups.add(current);
    return groups;
  }
}
