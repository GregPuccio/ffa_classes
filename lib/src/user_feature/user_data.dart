import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffaclasses/src/coach_feature/coach.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/constants/lists.dart';
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
  final List<Map<String, Map<String, List<DateTime>>>> availability;
  final List<LessonType> lessonTypes;

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
    required this.availability,
    required this.lessonTypes,
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
    List<Map<String, Map<String, List<DateTime>>>>? availability,
    List<LessonType>? lessonTypes,
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
      availability: availability ?? this.availability,
      lessonTypes: lessonTypes ?? this.lessonTypes,
    );
  }

  String get fullName {
    return "$parentFirstName $parentLastName";
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
      availability: availability,
      lessonTypes: lessonTypes,
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

  String get childrenFirstNames {
    List<String> firstNames = children.map((e) => e.firstName).toList();
    return firstNames.join(", ");
  }

  List<String> getSearchParams() {
    List<String> names =
        children.map((e) => e.firstName.toLowerCase()).toList();
    names.addAll([parentFirstName.toLowerCase(), parentLastName.toLowerCase()]);
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < names.length; i++) {
      temp = "";
      for (int j = 0; j < names[i].length; j++) {
        temp = temp + names[i][j];
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
      'searchTerms': getSearchParams(),
      'emailAddress': emailAddress,
      'parentFirstName': parentFirstName,
      'parentLastName': parentLastName,
      'children': children.map((x) => x.toMap()).toList(),
      'member': member,
      'unlimitedMember': unlimitedMember,
      'availability': availability,
      'lessonTypes': lessonTypes.map((x) => x.index).toList(),
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
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
    return UserData(
      id: map['id'],
      invoicingKey: map['invoicingKey'] ?? '',
      invoices: List<String>.from(map['invoices'] ?? []),
      admin: map['admin'] ?? false,
      emailAddress: map['emailAddress'],
      parentFirstName: map['parentFirstName'].trim(),
      parentLastName: map['parentLastName'].trim(),
      children: (map['children'] != null)
          ? List<Child>.from(map['children'].map((x) => Child.fromMap(x)))
          : [],
      member: map['member'] ?? false,
      unlimitedMember: map['unlimitedMember'] ?? false,
      availability: secondList,
      lessonTypes:
          List.from(map['lessonTypes']?.map((x) => LessonType.values[x]) ?? []),
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

  static List<Map<String, Map<String, List<DateTime>>>> createAvailability() {
    List<Map<String, Map<String, List<DateTime>>>> availability = [];
    for (int i = 0; i < daysOfWeek.length; i++) {
      availability.add({daysOfWeek[i]: {}});
    }
    return availability;
  }

  static UserData create() {
    return UserData(
      id: 'id',
      invoicingKey: '',
      invoices: [],
      admin: false,
      emailAddress: '',
      parentFirstName: '',
      parentLastName: '',
      children: [],
      member: false,
      unlimitedMember: false,
      availability: [],
      lessonTypes: [],
    );
  }

  static UserData fromCoach(Coach e) {
    return UserData.create().copyWith(
      id: e.id,
      emailAddress: e.emailAddress,
      parentFirstName: e.firstName,
      parentLastName: e.lastName,
      availability: e.availability,
      lessonTypes: e.lessonTypes,
    );
  }
}
