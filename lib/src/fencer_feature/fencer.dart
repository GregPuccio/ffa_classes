import 'dart:convert';

class Fencer {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool registerByParent;
  final String parentFirstName;
  final String parentLastName;
  Fencer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.registerByParent,
    required this.parentFirstName,
    required this.parentLastName,
  });

  Fencer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? registerByParent,
    String? parentFirstName,
    String? parentLastName,
  }) {
    return Fencer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      registerByParent: registerByParent ?? this.registerByParent,
      parentFirstName: parentFirstName ?? this.parentFirstName,
      parentLastName: parentLastName ?? this.parentLastName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'registerByParent': registerByParent,
      'parentFirstName': parentFirstName,
      'parentLastName': parentLastName,
    };
  }

  factory Fencer.fromMap(Map<String, dynamic> map) {
    return Fencer(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      registerByParent: map['registerByParent'],
      parentFirstName: map['parentFirstName'],
      parentLastName: map['parentLastName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Fencer.fromJson(String source) => Fencer.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Fencer(id: $id, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, registerByParent: $registerByParent, parentFirstName: $parentFirstName, parentLastName: $parentLastName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Fencer &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.registerByParent == registerByParent &&
        other.parentFirstName == parentFirstName &&
        other.parentLastName == parentLastName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        phoneNumber.hashCode ^
        registerByParent.hashCode ^
        parentFirstName.hashCode ^
        parentLastName.hashCode;
  }
}
