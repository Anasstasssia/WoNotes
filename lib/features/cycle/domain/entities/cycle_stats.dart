import 'package:flutter/foundation.dart';

@immutable
class CycleStats {
  final int currentCycleDay;
  final double averageCycleLength;
  final double averagePeriodLength;
  final bool isRegular;
  final String regularity;
  final DateTime? cycleStartDate;
  final int? lastCycleLength;
  final List<CyclePeriod> history;

  const CycleStats({
    required this.currentCycleDay,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.isRegular,
    required this.regularity,
    this.cycleStartDate,
    this.lastCycleLength,
    required this.history,
  });

  static const CycleStats empty = CycleStats(
    currentCycleDay: 0,
    averageCycleLength: 28,
    averagePeriodLength: 5,
    isRegular: true,
    regularity: 'Нет данных',
    history: [],
  );
}

@immutable
class CyclePeriod {
  final DateTime startDate;
  final DateTime endDate;
  final int length;
  final int periodLength;

  const CyclePeriod({
    required this.startDate,
    required this.endDate,
    required this.length,
    required this.periodLength,
  });

  String get dateRange {
    final start = '${startDate.day} ${_month(startDate.month)}';
    final end = '${endDate.day} ${_month(endDate.month)}';
    return '$start – $end';
  }

  static String _month(int m) => const [
        'янв',
        'фев',
        'мар',
        'апр',
        'май',
        'июн',
        'июл',
        'авг',
        'сен',
        'окт',
        'ноя',
        'дек',
      ][m - 1];
}
