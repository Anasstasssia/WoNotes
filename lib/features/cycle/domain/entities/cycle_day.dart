import 'package:flutter/foundation.dart';

enum CycleDayType { period, fertile, ovulation, normal }

@immutable
class CycleDay {
  final String id;
  final DateTime date;
  final CycleDayType type;

  const CycleDay({
    required this.id,
    required this.date,
    required this.type,
  });

  CycleDay copyWith({String? id, DateTime? date, CycleDayType? type}) =>
      CycleDay(
        id: id ?? this.id,
        date: date ?? this.date,
        type: type ?? this.type,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type.index,
      };

  factory CycleDay.fromJson(Map<String, dynamic> json) => CycleDay(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        type: CycleDayType.values[json['type'] as int],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CycleDay && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
