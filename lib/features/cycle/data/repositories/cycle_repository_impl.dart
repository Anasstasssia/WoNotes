import '../../domain/entities/cycle_day.dart';
import '../../domain/repositories/cycle_repository.dart';
import '../datasources/cycle_local_datasource.dart';

class CycleRepositoryImpl implements CycleRepository {
  final CycleLocalDatasource _ds;

  const CycleRepositoryImpl(this._ds);

  @override
  Future<List<CycleDay>> getAllDays() => _ds.getAllDays();

  @override
  Future<CycleDay?> getDayByDate(DateTime date) =>
      _ds.getDayByDate(date);

  @override
  Future<void> saveDay(CycleDay day) => _ds.saveDay(day);

  @override
  Future<void> deleteDayByDate(DateTime date) =>
      _ds.deleteDayByDate(date);
}
