import 'dart:convert';

class Child {
  String id;
  String firstName;
  String lastName;
  Child({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  Child copyWith({
    String? id,
    String? firstName,
    String? lastName,
  }) {
    return Child(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['id'],
      firstName: map['firstName'].trim(),
      lastName: map['lastName'].trim(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Child.fromJson(String source) => Child.fromMap(json.decode(source));

  @override
  String toString() =>
      'Child(id: $id, firstName: $firstName, lastName: $lastName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Child &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName;
  }

  @override
  int get hashCode => id.hashCode ^ firstName.hashCode ^ lastName.hashCode;
}
