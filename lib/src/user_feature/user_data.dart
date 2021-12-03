import 'dart:convert';

import 'package:ffaclasses/src/fencer_feature/fencer.dart';
import 'package:ffaclasses/src/user_feature/child.dart';

class UserData {
  final String id;
  final bool admin;
  final String emailAddress;
  final String parentFirstName;
  final String parentLastName;
  final List<Child> children;
  UserData({
    required this.id,
    required this.admin,
    required this.emailAddress,
    required this.parentFirstName,
    required this.parentLastName,
    required this.children,
  });

  UserData copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? emailAddress,
    bool? parentSignUp,
    String? parentFirstName,
    String? parentLastName,
    List<Child>? children,
  }) {
    return UserData(
      id: id ?? this.id,
      admin: admin,
      emailAddress: emailAddress ?? this.emailAddress,
      parentFirstName: parentFirstName ?? this.parentFirstName,
      parentLastName: parentLastName ?? this.parentLastName,
      children: children ?? this.children,
    );
  }

  Fencer toFencer(int childIndex) {
    return Fencer(
      id: id + childIndex.toString(),
      firstName: children[childIndex].firstName,
      lastName: children[childIndex].lastName,
      emailAddress: emailAddress,
      checkedIn: false,
    );
  }

  List<Fencer> fencers() {
    List<Fencer> newFencers = [];
    for (int i = 0; i < children.length; i++) {
      newFencers.add(Fencer(
        id: id + i.toString(),
        firstName: children[i].firstName,
        lastName: children[i].lastName,
        emailAddress: emailAddress,
        checkedIn: false,
      ));
    }
    return newFencers;
  }

  bool isFencerInList(List<Fencer> fencers) {
    if (fencers.isEmpty) {
      return false;
    } else {
      for (int i = 0; i < children.length; i++) {
        Fencer fencer = toFencer(i);
        if (fencers.contains(fencer)) {
          return true;
        }
      }
      return false;
    }
  }

  List<Fencer> fencersInList(List<Fencer> fencers) {
    List<Fencer> newFencers = [];

    if (fencers.isEmpty) {
      return newFencers;
    } else {
      for (int i = 0; i < children.length; i++) {
        Fencer fencer = toFencer(i);
        if (fencers.contains(fencer)) {
          newFencers.add(fencer);
        }
      }
      return newFencers;
    }
  }

  List<Fencer> fencersFromFirstName(List<String> firstNames) {
    List<Fencer> newFencers = [];
    for (var firstName in firstNames) {
      int index = children.indexWhere((child) => child.firstName == firstName);
      newFencers.add(toFencer(index));
    }
    return newFencers;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'admin': admin,
      'searchName': parentLastName.toLowerCase(),
      'emailAddress': emailAddress,
      'parentFirstName': parentFirstName,
      'parentLastName': parentLastName,
      'children': children.map((x) => x.toMap()).toList(),
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'],
      admin: map['admin'] ?? false,
      emailAddress: map['emailAddress'],
      parentFirstName: map['parentFirstName'],
      parentLastName: map['parentLastName'],
      children: (map['children'] != null)
          ? List<Child>.from(map['children'].map((x) => Child.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserData(id: $id, emailAddress: $emailAddress, parentFirstName: $parentFirstName, parentLastName: $parentLastName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserData &&
        other.id == id &&
        other.emailAddress == emailAddress &&
        other.parentFirstName == parentFirstName &&
        other.parentLastName == parentLastName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        emailAddress.hashCode ^
        parentFirstName.hashCode ^
        parentLastName.hashCode;
  }
}
