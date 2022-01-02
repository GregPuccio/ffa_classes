import 'dart:convert';

import 'package:ffaclasses/src/coach_feature/coach.dart';
import 'package:ffaclasses/src/fencer_feature/fencer.dart';
import 'package:ffaclasses/src/user_feature/child.dart';

class UserData {
  final String id;
  final String invoicingKey;
  final List<String> invoices;
  final bool admin;
  final String emailAddress;
  final String parentFirstName;
  final String parentLastName;
  final List<Child> children;
  final bool member;
  final bool unlimitedMember;

  UserData({
    required this.id,
    required this.invoicingKey,
    required this.invoices,
    required this.admin,
    required this.emailAddress,
    required this.parentFirstName,
    required this.parentLastName,
    required this.children,
    required this.member,
    required this.unlimitedMember,
  });

  UserData copyWith({
    String? id,
    String? invoicingKey,
    List<String>? invoices,
    String? emailAddress,
    String? parentFirstName,
    String? parentLastName,
    List<Child>? children,
    bool? member,
    bool? unlimitedMember,
  }) {
    return UserData(
      id: id ?? this.id,
      invoicingKey: invoicingKey ?? this.invoicingKey,
      invoices: invoices ?? this.invoices,
      admin: admin,
      emailAddress: emailAddress ?? this.emailAddress,
      parentFirstName: parentFirstName ?? this.parentFirstName,
      parentLastName: parentLastName ?? this.parentLastName,
      children: children ?? this.children,
      member: member ?? this.member,
      unlimitedMember: unlimitedMember ?? this.unlimitedMember,
    );
  }

  Fencer toFencer(int childIndex) {
    return Fencer(
      id: id + childIndex.toString(),
      firstName: children[childIndex].firstName,
      lastName: children[childIndex].lastName,
      emailAddress: emailAddress,
      checkedIn: false,
      registeredByID: id,
      registeredAt: DateTime.now(),
    );
  }

  Coach toCoach() {
    return Coach(
      id: id,
      emailAddress: emailAddress,
      firstName: parentFirstName,
      lastName: parentLastName,
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
        registeredByID: id,
        registeredAt: DateTime.now(),
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

  List<String> setSearchParam(List<String> fencerNames) {
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < fencerNames.length; i++) {
      temp = "";
      for (int j = 0; j < fencerNames[i].length; j++) {
        temp = temp + fencerNames[i][j];
        caseSearchList.add(temp);
      }
    }
    return caseSearchList;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoicingKey': invoicingKey,
      'invoices': invoices,
      'admin': admin,
      'searchTerms': setSearchParam(
          children.map((e) => e.firstName.toLowerCase()).toList()),
      'emailAddress': emailAddress,
      'parentFirstName': parentFirstName,
      'parentLastName': parentLastName,
      'children': children.map((x) => x.toMap()).toList(),
      'member': member,
      'unlimitedMember': unlimitedMember,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'],
      invoicingKey: map['invoicingKey'] ?? '',
      invoices: List<String>.from(map['invoices'] ?? []),
      admin: map['admin'] ?? false,
      emailAddress: map['emailAddress'],
      parentFirstName: map['parentFirstName'],
      parentLastName: map['parentLastName'],
      children: (map['children'] != null)
          ? List<Child>.from(map['children'].map((x) => Child.fromMap(x)))
          : [],
      member: map['member'] ?? false,
      unlimitedMember: map['unlimitedMember'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserData(id: $id, admin: $admin, emailAddress: $emailAddress, parentFirstName: $parentFirstName, parentLastName: $parentLastName, children: $children, member: $member, unlimitedMember: $unlimitedMember)';
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
        admin.hashCode ^
        emailAddress.hashCode ^
        parentFirstName.hashCode ^
        parentLastName.hashCode ^
        children.hashCode ^
        member.hashCode ^
        unlimitedMember.hashCode;
  }
}
