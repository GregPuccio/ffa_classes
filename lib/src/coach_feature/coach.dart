import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ffaclasses/src/constants/enums.dart';

class Coach {
  final String id;
  final String emailAddress;
  final String firstName;
  final String lastName;
  final List<Map<String, Map<String, List<DateTime>>>> availability;
  final List<LessonType> lessonTypes;
  Coach({
    required this.id,
    required this.emailAddress,
    required this.firstName,
    required this.lastName,
    required this.availability,
    required this.lessonTypes,
  });

  Coach copyWith({
    String? id,
    String? emailAddress,
    String? firstName,
    String? lastName,
    List<Map<String, Map<String, List<DateTime>>>>? availability,
    List<LessonType>? lessonTypes,
  }) {
    return Coach(
      id: id ?? this.id,
      emailAddress: emailAddress ?? this.emailAddress,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      availability: availability ?? this.availability,
      lessonTypes: lessonTypes ?? this.lessonTypes,
    );
  }

  String get fullName {
    return "$firstName $lastName";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emailAddress': emailAddress,
      'firstName': firstName,
      'lastName': lastName,
      'availability': availability,
      'lessonTypes': lessonTypes.map((x) => x.index).toList(),
    };
  }

  factory Coach.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> firstList =
        List<Map<String, dynamic>>.from(map['availability'] ?? []);
    List<Map<String, Map<String, List<DateTime>>>> secondList = firstList
        .map(
          (val) => val.map(
            (key, value) => MapEntry(
              key,
              Map<String, List<DateTime>>.from(
                value.map(
                  (key, value) => MapEntry(
                    key,
                    List<DateTime>.from(
                      value.map(
                        (e) => (e as Timestamp).toDate(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
    return Coach(
      id: map['id'] ?? '',
      emailAddress: map['emailAddress'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      availability: secondList,
      lessonTypes: List<LessonType>.from(
        map['lessonTypes']?.map((x) => LessonType.values[x ?? 0]) ?? [],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Coach.fromJson(String source) => Coach.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Coach(id: $id, emailAddress: $emailAddress, firstName: $firstName, lastName: $lastName, availability: $availability, lessonTypes: $lessonTypes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Coach && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        emailAddress.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        availability.hashCode ^
        lessonTypes.hashCode;
  }
}
