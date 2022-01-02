import 'dart:convert';

class Coach {
  final String id;
  final String emailAddress;
  final String firstName;
  final String lastName;
  Coach({
    required this.id,
    required this.emailAddress,
    required this.firstName,
    required this.lastName,
  });

  Coach copyWith({
    String? id,
    String? emailAddress,
    String? firstName,
    String? lastName,
  }) {
    return Coach(
      id: id ?? this.id,
      emailAddress: emailAddress ?? this.emailAddress,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emailAddress': emailAddress,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  factory Coach.fromMap(Map<String, dynamic> map) {
    return Coach(
      id: map['id'] ?? '',
      emailAddress: map['emailAddress'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Coach.fromJson(String source) => Coach.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Coach(id: $id, emailAddress: $emailAddress, firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Coach &&
      other.id == id &&
      other.emailAddress == emailAddress &&
      other.firstName == firstName &&
      other.lastName == lastName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      emailAddress.hashCode ^
      firstName.hashCode ^
      lastName.hashCode;
  }
}
