import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoiceninja/models/product.dart';

import 'package:ffaclasses/src/coach_feature/coach.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/fencer_feature/fencer.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';

class FClass implements Comparable {
  final String id;
  final DateTime date;
  final DateTime? endDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ClassType classType;
  final List<Coach> coaches;
  final String? customClassTitle;
  final String? customClassDescription;
  final String? customMaxFencers;
  final String? customRegRate;
  final String? customRegDiscount;
  final String? customUnlimRate;
  final String? customUnlimDiscount;
  final List<Fencer> fencers;
  final List<String> userIDs;
  final List<FClass>? campDays;
  FClass({
    required this.id,
    required this.date,
    this.endDate,
    required this.startTime,
    required this.endTime,
    required this.classType,
    required this.coaches,
    this.customClassTitle,
    this.customClassDescription,
    this.customMaxFencers,
    this.customRegRate,
    this.customRegDiscount,
    this.customUnlimRate,
    this.customUnlimDiscount,
    required this.fencers,
    required this.userIDs,
    this.campDays,
  });

  static FClass create({required ClassType classType}) {
    return FClass(
      id: 'id',
      date: DateTime.utc(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      startTime: const TimeOfDay(hour: 16, minute: 30),
      endTime: const TimeOfDay(hour: 18, minute: 00),
      classType: classType,
      fencers: [],
      userIDs: [],
      coaches: [],
    );
  }

  String get title {
    switch (classType) {
      case ClassType.camp:
        return customClassTitle ?? 'Custom Event';
      case ClassType.foundation:
        return "Foundation Class";
      case ClassType.youth:
        return "Youth Competitive Class";
      case ClassType.mixed:
        return "Mixed Competitive Class";
      case ClassType.advanced:
        return "Advanced Class";

      default:
        return "Sorry we couldn't find that class!";
    }
  }

  String get coachNames {
    List<String> coachFirstAndLast =
        coaches.map((e) => "${e.firstName} ${e.lastName}").toList();
    return coachFirstAndLast.join(", ");
  }

  String get webAddressID {
    if (customClassTitle != null) {
      List<String> title = customClassTitle!.split(" ");
      String url = "";
      for (var text in title) {
        if (url.isNotEmpty) {
          url = url + "-";
        }
        url = url + text;
      }
      return url;
    } else {
      return id;
    }
  }

  String get description {
    switch (classType) {
      case ClassType.camp:
        return customClassDescription ?? 'Custom Class Description';
      case ClassType.foundation:
        return "The class most suitable for younger and newer fencers (age 7-11) or by Coach invitation. This class focuses on coordination, fundamentals, and physical strategy games to build a correct technical base and to have fun and exercise! 12 max per class";
      case ClassType.youth:
        return "LIMITED TO 12 Open to any athlete age 10-14: YOUTH ATHLETES WHO ATTEND ADULT CLASSES MUST ATTEND AT LEAST ONE YOUTH or YOUTH COMPETITIVE CLASS PER WEEK";
      case ClassType.mixed:
        return "Open to any athlete age 10-14. YOUTH ATHLETES WHO ATTEND ADULT CLASSES MUST ATTEND AT LEAST ONE YOUTH CLASS PER WEEK";
      case ClassType.advanced:
        return "For experienced competitors 13+ or by Coach invitation";

      default:
        return "Sorry we couldn't find that class!";
    }
  }

  String get writtenDate {
    return "${DateFormat('EEEE').format(date)} ${date.month}/${date.day}/${date.year}";
  }

  String get dateRange {
    return "${DateFormat('E').format(date)} ${date.month}/${date.day}${endDate != null && endDate != date ? " - ${DateFormat('E').format(endDate!)} ${endDate!.month}/${endDate!.day}" : ''}";
  }

  String get writtenDay {
    return DateFormat('M/d').format(date);
  }

  String get maxFencerNumber {
    switch (classType) {
      case ClassType.camp:
        {
          if (customMaxFencers != null && customMaxFencers!.isNotEmpty) {
            return customMaxFencers!;
          } else {
            return "\u221E";
          }
        }
      case ClassType.foundation:
      case ClassType.youth:
        return "12";
      case ClassType.mixed:
      case ClassType.advanced:
        return "20";

      default:
        return "XX";
    }
  }

  List<String> findFencerCampDays(Fencer fencer) {
    List<String> days = [];
    if (campDays != null) {
      for (var day in campDays!) {
        if (day.fencers.contains(fencer)) {
          days.add(DateFormat('E M/d').format(day.date));
        }
      }
    }
    return days;
  }

  FClass copyWith({
    String? id,
    DateTime? date,
    DateTime? endDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? classType,
    List<Coach>? coaches,
    String? customClassTitle,
    String? customClassDescription,
    String? customMaxFencers,
    String? customRegRate,
    String? customRegDiscount,
    String? customUnlimRate,
    String? customUnlimDiscount,
    List<Fencer>? fencers,
    List<String>? userIDs,
    List<FClass>? campDays,
  }) {
    return FClass(
      id: id ?? this.id,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      classType: trueClassType(classType) ?? this.classType,
      coaches: coaches ?? this.coaches,
      customClassTitle: customClassTitle ?? this.customClassTitle,
      customClassDescription:
          customClassDescription ?? this.customClassDescription,
      customMaxFencers: customMaxFencers ?? this.customMaxFencers,
      customRegRate: customRegRate ?? this.customRegRate,
      customRegDiscount: customRegDiscount ?? this.customRegDiscount,
      customUnlimRate: customUnlimRate ?? this.customUnlimRate,
      customUnlimDiscount: customUnlimDiscount ?? this.customUnlimDiscount,
      fencers: fencers ?? this.fencers,
      userIDs: userIDs ?? this.userIDs,
      campDays: campDays ?? this.campDays,
    );
  }

  ClassType? trueClassType(String? classString) {
    switch (classString) {
      case 'Foundation':
        return ClassType.foundation;
      case 'Youth':
        return ClassType.youth;
      case 'Mixed':
        return ClassType.mixed;
      case 'Advanced':
        return ClassType.advanced;
      case 'Camp':
        return ClassType.camp;

      default:
        return null;
    }
  }

  String get writtenClassType {
    switch (classType) {
      case ClassType.foundation:
        return 'Foundation';
      case ClassType.youth:
        return 'Youth';
      case ClassType.mixed:
        return 'Mixed';
      case ClassType.advanced:
        return 'Advanced';
      case ClassType.camp:
        return "Camp";
    }
  }

  String? get classCost {
    switch (classType) {
      case ClassType.foundation:
        return 'Member: \$30 - Non Member: \$30';
      case ClassType.youth:
        return 'Member: \$40 - Non Member: \$50';
      case ClassType.mixed:
        return 'Member: \$40 - Non Member: \$50';
      case ClassType.advanced:
        return 'Member: \$40 - Non Member: \$50';
      case ClassType.camp:
        return "Regular: $customRegRate/day $customRegDiscount\nUnlimited: $customUnlimRate/day $customUnlimDiscount";

      default:
        return null;
    }
  }

  String getProductKey(bool member, bool unlimitedMember) {
    switch (classType) {
      case ClassType.foundation:
        return "Foundation Class";
      case ClassType.youth:
        if (member) {
          return "Youth Class";
        } else {
          return "Youth Class (Non-Member)";
        }
      case ClassType.mixed:
        if (member) {
          return "Mixed Class";
        } else {
          return "Mixed Class (Non-Member)";
        }
      case ClassType.advanced:
        if (member) {
          return "Advanced Class";
        } else {
          return "Advanced Class (Non-Member)";
        }
      case ClassType.camp:
        if (unlimitedMember) {
          return "Winter Camp (1 Day)";
        } else {
          return "Winter Camp (1 Day) (Non-Member)";
        }
    }
  }

  static List<Product> convertClassesToProducts(
      List<FClass> classes, List<Product> products, UserData userData) {
    List<Product> invoiceProducts = [];
    for (var fClass in classes) {
      if (fClass.classType != ClassType.camp) {
        invoiceProducts.add(products.firstWhere((product) =>
            product.productKey ==
            fClass.getProductKey(userData.member, userData.unlimitedMember)));
      } else {
        for (var id in fClass.userIDs) {
          if (id.substring(0, id.length - 1) == userData.id) {
            invoiceProducts.add(products.firstWhere((product) =>
                product.productKey ==
                fClass.getProductKey(
                    userData.member, userData.unlimitedMember)));
          }
        }
      }
    }
    return invoiceProducts;
  }

  List<Fencer> fencersOnDay(int index) {
    if (index == -1) {
      return fencers;
    } else if (campDays != null && campDays!.length >= index) {
      return campDays![index].fencers;
    } else {
      return fencers;
    }
  }

  static List<List<FClass>> sortClassesByDate(List<FClass> classes) {
    List<DateTime> dates = [];
    DateTime now = DateTime.now();
    DateTime lastDay = DateTime.utc(now.year, now.month + 1)
        .subtract(const Duration(hours: 24));
    for (int i = 1; i <= lastDay.day; i++) {
      dates.add(DateTime.utc(now.year, now.month, i));
    }
    List<List<FClass>> listOfListOfClasses = [];
    for (var date in dates) {
      List<FClass> newList = [];
      for (var fClass in classes) {
        if (fClass.campDays != null) {
          for (var day in fClass.campDays!) {
            if (day.date == date) {
              newList.add(day.copyWith(id: fClass.id));
            }
          }
        } else if (fClass.date == date) {
          newList.add(fClass);
        }
      }
      listOfListOfClasses.add(newList);
    }
    return listOfListOfClasses;
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'startTime': DateTime.utc(1)
          .add(Duration(hours: startTime.hour, minutes: startTime.minute))
          .millisecondsSinceEpoch,
      'endTime': DateTime.utc(1)
          .add(Duration(hours: endTime.hour, minutes: endTime.minute))
          .millisecondsSinceEpoch,
      'coaches': coaches.map((x) => x.toMap()).toList(),
      'classType': classType.index,
      'customClassTitle': customClassTitle,
      'customClassDescription': customClassDescription,
      'customMaxFencers': customMaxFencers,
      'customRegRate': customRegRate,
      'customRegDiscount': customRegDiscount,
      'customUnlimRate': customUnlimRate,
      'customUnlimDiscount': customUnlimDiscount,
      'fencers': fencers.map((x) => x.toMap()).toList(),
      'userIDs': userIDs,
      'campDays': campDays?.map((e) => e.toMap()).toList(),
    };
  }

  factory FClass.fromMap(Map<String, dynamic> map) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(map['date'], isUtc: true);
    DateTime? endDate;
    if (map['endDate'] != null) {
      endDate =
          DateTime.fromMillisecondsSinceEpoch(map['endDate'], isUtc: true);
      endDate = DateTime.utc(endDate.year, endDate.month, endDate.day);
    }
    return FClass(
      id: '',
      date: DateTime.utc(date.year, date.month, date.day),
      endDate: endDate,
      startTime: TimeOfDay.fromDateTime(
          DateTime.fromMillisecondsSinceEpoch(map['startTime'], isUtc: true)),
      endTime: TimeOfDay.fromDateTime(
          DateTime.fromMillisecondsSinceEpoch(map['endTime'], isUtc: true)),
      coaches: List<Coach>.from(
        map['coaches']?.map((x) => Coach.fromMap(x)) ?? [],
      ),
      classType: ClassType.values[map['classType']],
      customClassTitle: map['customClassTitle'],
      customClassDescription: map['customClassDescription'],
      customMaxFencers: map['customMaxFencers'],
      customRegRate: map['customRegRate'],
      customRegDiscount: map['customRegDiscount'],
      customUnlimRate: map['customUnlimRate'],
      customUnlimDiscount: map['customUnlimDiscount'],
      fencers: List<Fencer>.from(
          map['fencers']?.map((x) => Fencer.fromMap(x)) ?? []),
      userIDs: List<String>.from(map['userIDs'] ?? []),
      campDays: map['campDays'] != null
          ? List<FClass>.from(map['campDays'].map((x) => FClass.fromMap(x)))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FClass.fromJson(String source) => FClass.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FClass(id: $id, date: $date, endDate: $endDate, startTime: $startTime, endTime: $endTime, classType: $classType, coaches: $coaches, customClassTitle: $customClassTitle, customClassDescription: $customClassDescription, customMaxFencers: $customMaxFencers, customRegRate: $customRegRate, customRegDiscount: $customRegDiscount, customUnlimRate: $customUnlimRate, customUnlimDiscount: $customUnlimDiscount, fencers: $fencers, userIDs: $userIDs, campDays: $campDays)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FClass &&
        other.id == id &&
        other.date == date &&
        other.endDate == endDate &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.classType == classType &&
        listEquals(other.coaches, coaches) &&
        other.customClassTitle == customClassTitle &&
        other.customClassDescription == customClassDescription &&
        other.customMaxFencers == customMaxFencers &&
        other.customRegRate == customRegRate &&
        other.customRegDiscount == customRegDiscount &&
        other.customUnlimRate == customUnlimRate &&
        other.customUnlimDiscount == customUnlimDiscount &&
        listEquals(other.fencers, fencers) &&
        listEquals(other.userIDs, userIDs) &&
        listEquals(other.campDays, campDays);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        endDate.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        classType.hashCode ^
        coaches.hashCode ^
        customClassTitle.hashCode ^
        customClassDescription.hashCode ^
        customMaxFencers.hashCode ^
        customRegRate.hashCode ^
        customRegDiscount.hashCode ^
        customUnlimRate.hashCode ^
        customUnlimDiscount.hashCode ^
        fencers.hashCode ^
        userIDs.hashCode ^
        campDays.hashCode;
  }

  @override
  int compareTo(other) {
    if (date == other.date) {
      if (startTime.hour < other.startTime.hour) {
        return -1;
      } else {
        return 1;
      }
    } else if (date.isBefore(other.date)) {
      return -1;
    } else {
      return 1;
    }
  }
}
