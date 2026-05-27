import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/cycle_local_datasource.dart';
import '../../data/repositories/cycle_repository_impl.dart';
import '../../domain/entities/cycle_day.dart';
import '../../domain/entities/cycle_stats.dart';
import '../../domain/repositories/cycle_repository.dart';
import '../../domain/usecases/cycle_calculator.dart';
import '../../../../core/constants/app_constants.dart';

final _cycleRepositoryProvider = Provider<CycleRepository>((ref) {
  final box = Hive.box<String>(AppConstants.cycleDaysBox);
  return CycleRepositoryImpl(CycleLocalDatasource(box));
});

// ─── State ────────────────────────────────────────────────────────────────────

class CycleState {
  final List<CycleDay> days;
  final bool isLoading;
  final DateTime focusedMonth;

  CycleState({
    this.days = const [],
    this.isLoading = false,
    DateTime? focusedMonth,
  }) : focusedMonth = focusedMonth ?? DateTime.now();

  CycleState copyWith({
    List<CycleDay>? days,
    bool? isLoading,
    DateTime? focusedMonth,
  }) =>
      CycleState(
        days: days ?? this.days,
        isLoading: isLoading ?? this.isLoading,
        focusedMonth: focusedMonth ?? this.focusedMonth,
      );

  Map<DateTime, CycleDayType> get markedDays =>
      {for (final d in days) _norm(d.date): d.type};

  Map<DateTime, CycleDayType> get predictedFertile {
    final s = stats;
    return CycleCalculator.fertileWindow(days, s.averageCycleLength);
  }

  CycleStats get stats => CycleCalculator.calculate(days);

  bool isPeriodDay(DateTime date) =>
      markedDays[_norm(date)] == CycleDayType.period;

  static DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class CycleNotifier extends StateNotifier<CycleState> {
  final CycleRepository _repo;
  static const _uuid = Uuid();

  CycleNotifier(this._repo) : super(CycleState()) {
    loadDays();
  }

  Future<void> loadDays() async {
    state = state.copyWith(isLoading: true);
    final days = await _repo.getAllDays();
    state = state.copyWith(days: days, isLoading: false);
  }

  Future<void> togglePeriodDay(DateTime date) async {
    final norm = DateTime(date.year, date.month, date.day);
    final existing = await _repo.getDayByDate(norm);
    if (existing != null) {
      await _repo.deleteDayByDate(norm);
    } else {
      await _repo.saveDay(CycleDay(
        id: _uuid.v4(),
        date: norm,
        type: CycleDayType.period,
      ));
    }
    await loadDays();
  }

  void setFocusedMonth(DateTime month) =>
      state = state.copyWith(focusedMonth: month);
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final cycleProvider =
    StateNotifierProvider<CycleNotifier, CycleState>((ref) {
  final repo = ref.watch(_cycleRepositoryProvider);
  return CycleNotifier(repo);
});
