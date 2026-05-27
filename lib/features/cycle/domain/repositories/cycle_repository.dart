import '../entities/cycle_day.dart';

abstract class CycleRepository {
  Future<List<CycleDay>> getAllDays();
  Future<CycleDay?> getDayByDate(DateTime date);
  Future<void> saveDay(CycleDay day);
  Future<void> deleteDayByDate(DateTime date);
}
