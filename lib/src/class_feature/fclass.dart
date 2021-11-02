import 'dart:convert';

import 'package:ffaclasses/src/fencer_feature/fencer.dart';
import 'package:flutter/foundation.dart';

import 'package:ffaclasses/src/constants/enums.dart';

class FClass {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int cost;
  final ClassType classType;
  final List<Fencer> fencers;
  FClass({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.cost,
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

  String get dates {
    String startDate = startTime.toString();
    String endDate = endTime.toString();
    return '$startDate - $endDate';
  }

  FClass copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? cost,
    ClassType? classType,
    List<Fencer>? fencers,
  }) {
    return FClass(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cost: cost ?? this.cost,
      classType: classType ?? this.classType,
      fencers: fencers ?? this.fencers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'cost': cost,
      'classType': classType.index,
      'fencers': fencers.map((x) => x.toMap()).toList(),
    };
  }

  factory FClass.fromMap(Map<String, dynamic> map) {
    return FClass(
      id: map['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      cost: map['cost'],
      classType: ClassType.values[map['classType']],
      fencers: List<Fencer>.from(map['fencers']?.map((x) => Fencer.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory FClass.fromJson(String source) => FClass.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FClass(id: $id, startTime: $startTime, endTime: $endTime, cost: $cost, classType: $classType, fencers: $fencers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FClass &&
        other.id == id &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.cost == cost &&
        other.classType == classType &&
        listEquals(other.fencers, fencers);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        cost.hashCode ^
        classType.hashCode ^
        fencers.hashCode;
  }
}
