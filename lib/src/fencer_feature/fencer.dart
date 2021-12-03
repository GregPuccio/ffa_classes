import 'dart:convert';

class Fencer {
  final String id;
  final String firstName;
  final String lastName;
  final String emailAddress;
  final bool checkedIn;
  Fencer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.checkedIn,
  });

  Fencer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? emailAddress,
    bool? checkedIn,
  }) {
    return Fencer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      emailAddress: emailAddress ?? this.emailAddress,
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
      'searchName': firstName.toLowerCase(),
      'lastName': lastName,
      'emailAddress': emailAddress,
      'checkedIn': checkedIn,
    };
  }

  static List<Fencer> fromUserMap(Map<String, dynamic> map) {
    List fencerMap = map['children'];
    return List.generate(
      fencerMap.length,
      (index) => Fencer(
        id: fencerMap[index]['id'],
        firstName: fencerMap[index]['firstName'],
        lastName: fencerMap[index]['lastName'],
        emailAddress: map['emailAddress'],
        checkedIn: fencerMap[index]['checkedIn'] ?? false,
      ),
    );
  }

  factory Fencer.fromMap(Map<String, dynamic> map) {
    return Fencer(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      emailAddress: map['emailAddress'],
      checkedIn: map['checkedIn'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Fencer.fromJson(String source) => Fencer.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Fencer(id: $id, firstName: $firstName, lastName: $lastName, emailAddress: $emailAddress, checkedIn: $checkedIn)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Fencer &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.emailAddress == emailAddress;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        emailAddress.hashCode ^
        checkedIn.hashCode;
  }
}
