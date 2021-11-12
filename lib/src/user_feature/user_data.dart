import 'dart:convert';

import 'package:ffaclasses/src/fencer_feature/fencer.dart';

class UserData {
  final String id;
  final bool admin;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool parentSignUp;
  final String parentFirstName;
  final String parentLastName;
  UserData({
    required this.id,
    required this.admin,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.parentSignUp,
    required this.parentFirstName,
    required this.parentLastName,
  });

  UserData copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? parentSignUp,
    String? parentFirstName,
    String? parentLastName,
  }) {
    return UserData(
      id: id ?? this.id,
      admin: admin,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      parentSignUp: parentSignUp ?? this.parentSignUp,
      parentFirstName: parentFirstName ?? this.parentFirstName,
      parentLastName: parentLastName ?? this.parentLastName,
    );
  }

  Fencer toFencer() {
    return Fencer(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      checkedIn: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'admin': admin,
      'firstName': firstName,
      'searchName': firstName.toLowerCase(),
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'parentSignUp': parentSignUp,
      'parentFirstName': parentFirstName,
      'parentLastName': parentLastName,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'],
      admin: map['admin'] ?? false,
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      parentSignUp: map['parentSignUp'],
      parentFirstName: map['parentFirstName'],
      parentLastName: map['parentLastName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserData(id: $id, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, parentSignUp: $parentSignUp, parentFirstName: $parentFirstName, parentLastName: $parentLastName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserData &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.parentSignUp == parentSignUp &&
        other.parentFirstName == parentFirstName &&
        other.parentLastName == parentLastName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        phoneNumber.hashCode ^
        parentSignUp.hashCode ^
        parentFirstName.hashCode ^
        parentLastName.hashCode;
  }
}
