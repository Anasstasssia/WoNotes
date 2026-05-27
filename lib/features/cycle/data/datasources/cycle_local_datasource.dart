import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/cycle_day.dart';

class CycleLocalDatasource {
  final Box<String> _box;

  const CycleLocalDatasource(this._box);

  static String _key(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<List<CycleDay>> getAllDays() async {
    final days = <CycleDay>[];
    for (final key in _box.keys) {
      final raw = _box.get(key as String);
      if (raw == null) continue;
      try {
        days.add(
            CycleDay.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {}
    }
    days.sort((a, b) => a.date.compareTo(b.date));
    return days;
  }

  Future<CycleDay?> getDayByDate(DateTime date) async {
    final raw = _box.get(_key(date));
    if (raw == null) return null;
    return CycleDay.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveDay(CycleDay day) =>
      _box.put(_key(day.date), jsonEncode(day.toJson()));

  Future<void> deleteDayByDate(DateTime date) =>
      _box.delete(_key(date));
}
