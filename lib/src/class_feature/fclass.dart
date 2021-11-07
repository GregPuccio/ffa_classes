import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/fencer_feature/fencer.dart';

class FClass {
  final String id;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ClassType classType;
  final List<Fencer> fencers;
  FClass({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.classType,
    required this.fencers,
  });

  String get title {
    switch (classType) {
      case ClassType.foundation:
        return "Foundation";
      case ClassType.youth:
        return "Youth Competitive";
      case ClassType.mixed:
        return "Mixed Competitive";
      case ClassType.advanced:
        return "Advanced";

      default:
        return "Sorry we couldn't find that class!";
    }
  }

  String get description {
    switch (classType) {
      case ClassType.foundation:
        return "The class most suitable for younger and newer fencers (age 7-11) or by Coach invitation. This class focuses on coordination, fundamentals, and physical strategy games to build a correct technical base and to have fun and exercise! 12 max per class";
      case ClassType.youth:
        return "LIMITED TO 12 Open to any athlete age 10-14: YOUTH ATHLETES WHO ATTEND ADULT CLASSES MUST ATTEND AT LEAST ONE YOUTH or YOUTH COMPETITIVE CLASS PER WEEK";
      case ClassType.mixed:
        return "Open to any athlete age 10-14. YOUTH ATHLETES WHO ATTEND ADULT CLASSES MUST ATTEND AT LEAST ONE YOUTH CLASS PER WEEK";
      case ClassType.advanced:
        return "For experienced competitors 13+ or by Coach invitation";

      default:
        return "Sorry we couldn't find that class!";
    }
  }

  String get writtenDate {
    return "${DateFormat('EEEE').format(date)} ${date.month}/${date.day}/${date.year}";
  }

  FClass copyWith({
    String? id,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? cost,
    String? classType,
    List<Fencer>? fencers,
  }) {
    return FClass(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      classType: trueClassType(classType) ?? this.classType,
      fencers: fencers ?? this.fencers,
    );
  }

  ClassType? trueClassType(String? classString) {
    switch (classString) {
      case 'Foundation':
        return ClassType.foundation;
      case 'Youth':
        return ClassType.youth;
      case 'Mixed':
        return ClassType.mixed;
      case 'Advanced':
        return ClassType.advanced;

      default:
        return null;
    }
  }

  String get writtenClassType {
    switch (classType) {
      case ClassType.foundation:
        return 'Foundation';
      case ClassType.youth:
        return 'Youth Competitive';
      case ClassType.mixed:
        return 'Mixed Competitive';
      case ClassType.advanced:
        return 'Advanced';

      default:
        return 'Foundation';
    }
  }

  String get classCost {
    switch (classType) {
      case ClassType.foundation:
        return 'Member: \$30 - Non Member: \$30';
      case ClassType.youth:
        return 'Member: \$40 - Non Member: \$50';
      case ClassType.mixed:
        return 'Member: \$40 - Non Member: \$50';
      case ClassType.advanced:
        return 'Member: \$40 - Non Member: \$50';

      default:
        return 'Class incorrectly set up.';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'startTime': DateTime(1)
          .add(Duration(hours: startTime.hour, minutes: startTime.minute))
          .millisecondsSinceEpoch,
      'endTime': DateTime(1)
          .add(Duration(hours: endTime.hour, minutes: endTime.minute))
          .millisecondsSinceEpoch,
      'classType': classType.index,
      'fencers': fencers.map((x) => x.toMap()).toList(),
    };
  }

  factory FClass.fromMap(Map<String, dynamic> map) {
    return FClass(
      id: '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      startTime: TimeOfDay.fromDateTime(
          DateTime.fromMillisecondsSinceEpoch(map['startTime'])),
      endTime: TimeOfDay.fromDateTime(
          DateTime.fromMillisecondsSinceEpoch(map['endTime'])),
      classType: ClassType.values[map['classType']],
      fencers: List<Fencer>.from(map['fencers']?.map((x) => Fencer.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory FClass.fromJson(String source) => FClass.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FClass(id: $id, date: $date, startTime: $startTime, endTime: $endTime, classType: $classType, fencers: $fencers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FClass &&
        other.id == id &&
        other.date == date &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.classType == classType &&
        listEquals(other.fencers, fencers);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        classType.hashCode ^
        fencers.hashCode;
  }
}
