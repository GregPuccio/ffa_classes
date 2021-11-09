import 'dart:convert';

class Fencer {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool checkedIn;
  Fencer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.checkedIn,
  });

  Fencer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? checkedIn,
  }) {
    return Fencer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      checkedIn: checkedIn ?? this.checkedIn,
    );
  }

  String get name {
    return "$firstName ${lastName.substring(0, 1)}.";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'searchName': firstName.toLowerCase(),
      'phoneNumber': phoneNumber,
      'checkedIn': checkedIn,
    };
  }

  factory Fencer.fromMap(Map<String, dynamic> map) {
    return Fencer(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      checkedIn: map['checkedIn'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Fencer.fromJson(String source) => Fencer.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Fencer(id: $id, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, checkedIn: $checkedIn)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Fencer &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.checkedIn == checkedIn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        phoneNumber.hashCode ^
        checkedIn.hashCode;
  }
}
