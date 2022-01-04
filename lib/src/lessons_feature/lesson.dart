import 'dart:convert';

import 'package:ffaclasses/src/coach_feature/coach.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/fencer_feature/fencer.dart';

class Lesson {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final Coach coach;
  final Fencer fencer;
  final String userID;
  final LessonType lessonType;
  String notes;
  Lesson({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.coach,
    required this.fencer,
    required this.userID,
    required this.lessonType,
    required this.notes,
  });

  Lesson copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    Coach? coach,
    Fencer? fencer,
    String? userID,
    LessonType? lessonType,
    String? notes,
  }) {
    return Lesson(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      coach: coach ?? this.coach,
      fencer: fencer ?? this.fencer,
      userID: userID ?? this.userID,
      lessonType: lessonType ?? this.lessonType,
      notes: notes ?? this.notes,
    );
  }

  String get description {
    switch (lessonType) {
      case LessonType.privateLesson:
        return "20 minute private lesson";
      case LessonType.boutingLesson:
        return "30 minute active, situational bouting with self strip coaching training";
    }
  }

  String get length {
    switch (lessonType) {
      case LessonType.privateLesson:
        return "20 minutes";
      case LessonType.boutingLesson:
        return "30 minutes";
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'coach': coach.toMap(),
      'fencer': fencer.toMap(),
      'userID': userID,
      'lessonType': lessonType.index,
      'notes': notes,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      coach: Coach.fromMap(map['coach']),
      fencer: Fencer.fromMap(map['fencer']),
      userID: map['userID'] ?? '',
      lessonType: LessonType.values[map['lessonType']],
      notes: map['notes'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Lesson.fromJson(String source) => Lesson.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Lesson(id: $id, startTime: $startTime, endTime: $endTime, coach: $coach, fencer: $fencer, userID: $userID, lessonType: $lessonType, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Lesson &&
        other.id == id &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.coach == coach &&
        other.fencer == fencer &&
        other.userID == userID &&
        other.lessonType == lessonType &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        coach.hashCode ^
        fencer.hashCode ^
        userID.hashCode ^
        lessonType.hashCode ^
        notes.hashCode;
  }
}
