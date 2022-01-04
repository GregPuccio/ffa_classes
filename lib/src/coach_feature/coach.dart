import 'dart:convert';

import 'package:flutter/foundation.dart';

class Coach {
  final String id;
  final String emailAddress;
  final String firstName;
  final String lastName;
  final List<Map<String, Map<String, List<DateTime>>>> availability;
  Coach({
    required this.id,
    required this.emailAddress,
    required this.firstName,
    required this.lastName,
    required this.availability,
  });

  Coach copyWith({
    String? id,
    String? emailAddress,
    String? firstName,
    String? lastName,
    List<Map<String, Map<String, List<DateTime>>>>? availability,
  }) {
    return Coach(
      id: id ?? this.id,
      emailAddress: emailAddress ?? this.emailAddress,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      availability: availability ?? this.availability,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emailAddress': emailAddress,
      'firstName': firstName,
      'lastName': lastName,
      'availability': availability,
    };
  }

  factory Coach.fromMap(Map<String, dynamic> map) {
    return Coach(
      id: map['id'] ?? '',
      emailAddress: map['emailAddress'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      availability: List<Map<String, Map<String, List<DateTime>>>>.from(
          map['availability'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Coach.fromJson(String source) => Coach.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Coach(id: $id, emailAddress: $emailAddress, firstName: $firstName, lastName: $lastName, availability: $availability)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Coach &&
        other.id == id &&
        other.emailAddress == emailAddress &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        listEquals(other.availability, availability);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        emailAddress.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        availability.hashCode;
  }
}
