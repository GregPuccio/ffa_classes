import 'dart:collection';

import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/coach_feature/coach.dart';
import 'package:ffaclasses/src/constants/coach_data.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/constants/lists.dart';
import 'package:ffaclasses/src/constants/widgets/search_bar.dart';
import 'package:ffaclasses/src/fencer_feature/fencer.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/lessons_feature/lesson.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AddStudentLesson extends StatefulWidget {
  const AddStudentLesson({Key? key}) : super(key: key);
  static const routeName = 'addStudentLesson';

  @override
  _AddStudentLessonState createState() => _AddStudentLessonState();
}

class _AddStudentLessonState extends State<AddStudentLesson> {
  final AutoScrollController _scrollController =
      AutoScrollController(suggestedRowHeight: 125);
  late TextEditingController controller;
  LessonType? _lessonType;
  Coach? coach;
  Fencer? fencer;

  late ValueNotifier<List<Lesson>> _selectedLessons;

  DateTime? _selectedDay;

  DateTime _focusedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  LinkedHashMap<DateTime, List<Lesson>> lessons = LinkedHashMap();

  List<Lesson> _getLessonsForDay(
      DateTime? day, List<List<DateTime>>? lessonSlots) {
    List<Lesson> lessons = [];
    if (lessonSlots != null && day != null) {
      for (int i = 0; i < lessonSlots.length; i++) {
        DateTime startTime = DateTime(day.year, day.month, day.day,
            lessonSlots[i].first.hour, lessonSlots[i].first.minute);
        DateTime endTime = DateTime(day.year, day.month, day.day,
            lessonSlots[i].last.hour, lessonSlots[i].last.minute);
        Lesson lesson = Lesson.create().copyWith(
          startTime: startTime,
          endTime: endTime,
          coach: coach,
          fencer: fencer,
          userID: fencer!.id.substring(0, fencer!.id.length - 1),
          lessonType: _lessonType,
        );
        lessons.add(lesson);
      }
      return lessons;
    } else {
      return [];
    }
  }

  Future<List<Lesson>> getLessonTimeSlotsForDay(
      List<Lesson> lessonSlots) async {
    if (lessonSlots.isNotEmpty) {
      DateTime start = lessonSlots.first.startTime;
      DateTime earliest = DateTime(start.year, start.month, start.day);
      DateTime latest = DateTime(start.year, start.month, start.day + 1);
      List<Lesson> bookedLessons = await FirestoreService().collectionFuture(
          path: FirestorePath.lessons(),
          builder: (map, docID) => Lesson.fromMap(map!).copyWith(id: docID),
          queryBuilder: (query) {
            return query
                .where('startTime',
                    isGreaterThanOrEqualTo: earliest.millisecondsSinceEpoch)
                .where('startTime', isLessThan: latest.millisecondsSinceEpoch);
          });
      List<Lesson> lessons = [];
      for (int i = 0; i < lessonSlots.length; i++) {
        DateTime startTime = lessonSlots[i].startTime;
        DateTime endTime = lessonSlots[i].endTime;
        int lessonLength = _lessonType == LessonType.privateLesson ? 20 : 30;
        int timeSlots = endTime.difference(startTime).inMinutes ~/ lessonLength;
        for (int j = 0; j < timeSlots; j++) {
          Lesson lesson = Lesson.create().copyWith(
            startTime: startTime.add(Duration(minutes: lessonLength * j)),
            endTime: startTime.add(Duration(minutes: lessonLength * (j + 1))),
            coach: coach,
            fencer: fencer,
            userID: fencer!.id.substring(0, fencer!.id.length - 1),
            lessonType: _lessonType,
          );
          if (bookedLessons.any((bookedLesson) =>
              (bookedLesson.startTime.isAtSameMomentAs(lesson.startTime) ||
                  (bookedLesson.startTime.isAfter(lesson.startTime) &&
                      bookedLesson.startTime.isBefore(lesson.endTime))) &&
              lesson.coach.id == bookedLesson.coach.id)) {
            lesson = lesson.copyWith(booked: true);
          }
          lessons.add(lesson);
        }
      }
      return lessons;
    } else {
      return [];
    }
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    _selectedDay = _focusedDay;
    _selectedLessons = ValueNotifier(_getLessonsForDay(_selectedDay, []));
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _selectedLessons.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Add Lesson"),
            bottom: SearchBar(
              controller,
              Theme.of(context).cardColor,
              autoComplete: true,
              onResult: (Fencer result) => setState(() {
                fencer = result;
              }),
            ),
          ),
          body: ListView.builder(
            controller: _scrollController,
            itemCount: 6,
            itemBuilder: (context, index) {
              if (index == 0) {
                return fencer != null
                    ? AutoScrollTag(
                        key: ValueKey(index),
                        index: index,
                        controller: _scrollController,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Fencer Selected: ${fencer!.name}",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
                      )
                    : Container();
              }
              if (index < 3) {
                return AutoScrollTag(
                  key: ValueKey(index),
                  index: index,
                  controller: _scrollController,
                  child: fencer != null
                      ? Column(
                          children: [
                            if (index == 1)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Choose the type of lesson that you would like to sign ${fencer!.firstName} up for:",
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                            RadioListTile(
                              controlAffinity: ListTileControlAffinity.platform,
                              title: Text(Lesson.typeFromType(
                                  LessonType.values[index - 1])),
                              value: LessonType.values[index - 1],
                              groupValue: _lessonType,
                              onChanged: (val) {
                                setState(() {
                                  _lessonType = LessonType.values[index - 1];
                                  if (index == 1) {
                                    coach = zackBrown;
                                    _scrollController.scrollToIndex(3);
                                    _selectedLessons.value =
                                        _getLessonsForDay(_selectedDay, []);
                                  } else {
                                    coach = null;
                                  }
                                });
                              },
                            ),
                            ...[
                              if (index == 1 &&
                                  _lessonType == LessonType.privateLesson)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0),
                                  child: RadioListTile(
                                    controlAffinity:
                                        ListTileControlAffinity.platform,
                                    title: const Text(
                                      "Zack Brown",
                                    ),
                                    value: zackBrown,
                                    groupValue: coach,
                                    onChanged: (val) {
                                      setState(() {
                                        coach = zackBrown;
                                      });
                                      _scrollController.scrollToIndex(3);
                                    },
                                  ),
                                ),
                              if (index != 1 &&
                                  _lessonType == LessonType.boutingLesson) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0),
                                  child: RadioListTile(
                                    controlAffinity:
                                        ListTileControlAffinity.platform,
                                    title: const Text(
                                      "Greg Puccio",
                                    ),
                                    value: gregPuccio,
                                    groupValue: coach,
                                    onChanged: (val) {
                                      setState(() {
                                        coach = gregPuccio;
                                        _selectedLessons.value =
                                            _getLessonsForDay(_selectedDay, []);
                                      });
                                      _scrollController.scrollToIndex(3);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0),
                                  child: RadioListTile(
                                    controlAffinity:
                                        ListTileControlAffinity.platform,
                                    title: const Text(
                                      "Andrew Richardson",
                                    ),
                                    value: andrewRichardson,
                                    groupValue: coach,
                                    onChanged: (val) {
                                      setState(() {
                                        coach = andrewRichardson;
                                        _selectedLessons.value =
                                            _getLessonsForDay(_selectedDay, []);
                                      });
                                      _scrollController.scrollToIndex(3);
                                    },
                                  ),
                                ),
                              ],
                              if (index != 1) const Divider(),
                            ],
                          ],
                        )
                      : Container(),
                );
              } else if (index == 3) {
                return AutoScrollTag(
                  key: ValueKey(index),
                  index: index,
                  controller: _scrollController,
                  child: _lessonType != null && coach != null
                      ? StreamBuilder<UserData>(
                          stream: FirestoreService().documentStream(
                              path: FirestorePath.user(coach!.id),
                              builder: (map, docID) =>
                                  UserData.fromMap(map!).copyWith(id: docID)),
                          builder: (context, snapshot) {
                            DateTime rawNow = DateTime.now();
                            DateTime now =
                                DateTime(rawNow.year, rawNow.month, rawNow.day);
                            if (snapshot.hasData && snapshot.data != null) {
                              UserData coach = snapshot.data!;
                              Map<String, List<List<DateTime>>> availability =
                                  {};
                              for (int i = 0; i < daysOfWeek.length; i++) {
                                String day = daysOfWeek[i];
                                List<List<DateTime>> dates = [];

                                dates = coach.availability
                                    .firstWhere(
                                      (map) => map.containsKey(day),
                                    )
                                    .entries
                                    .firstWhere((element) => element.key == day)
                                    .value
                                    .values
                                    .toList();
                                availability.addEntries([MapEntry(day, dates)]);
                              }

                              return TableCalendar(
                                availableCalendarFormats: const {
                                  CalendarFormat.month: 'Month',
                                },
                                firstDay: now,
                                lastDay: now.add(
                                  const Duration(days: 365),
                                ),
                                pageJumpingEnabled: true,
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) {
                                  return isSameDay(_selectedDay, day);
                                },
                                onDaySelected: (selectedDay, focusedDay) {
                                  MapEntry<String, List<List<DateTime>>> entry =
                                      availability.entries.firstWhere((entry) =>
                                          entry.key ==
                                          DateFormat('EEEE')
                                              .format(focusedDay));
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                    _selectedLessons.value = _getLessonsForDay(
                                        selectedDay, entry.value);
                                  });
                                  // if (_selectedLessons.value.isNotEmpty) {
                                  //   _scrollController.scrollToIndex(index + 3);
                                  // }
                                },
                                onPageChanged: (focusedDay) {
                                  _focusedDay = focusedDay;
                                },
                                eventLoader: (day) {
                                  MapEntry<String, List<List<DateTime>>> entry =
                                      availability.entries.firstWhere((entry) =>
                                          entry.key ==
                                          DateFormat('EEEE').format(day));
                                  return _getLessonsForDay(day, entry.value);
                                },
                              );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        )
                      : Container(),
                );
              } else if (index == 4) {
                return AutoScrollTag(
                  key: ValueKey(index),
                  index: index,
                  controller: _scrollController,
                  child: _lessonType != null && coach != null
                      ? ValueListenableBuilder<List<Lesson>>(
                          valueListenable: _selectedLessons,
                          builder: (context, rawLessons, _) {
                            return FutureBuilder<List<Lesson>>(
                                future: getLessonTimeSlotsForDay(rawLessons),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<Lesson> lessons = snapshot.data!;
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Divider(),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Please select a timeslot to register for:",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          ),
                                        ),
                                        Wrap(
                                          runAlignment: WrapAlignment.center,
                                          children: lessons
                                              .map((lesson) => Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: ElevatedButton(
                                                      onPressed: lesson.booked
                                                          ? null
                                                          : () async {
                                                              bool? result =
                                                                  await showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                    title:
                                                                        const Text(
                                                                      "Register for Lesson",
                                                                    ),
                                                                    content:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const Text(
                                                                            "Please confirm the following information before registering:"),
                                                                        Table(
                                                                          children: [
                                                                            TableRow(
                                                                              children: [
                                                                                const Text("Lesson Type:"),
                                                                                Text(lesson.type),
                                                                              ],
                                                                            ),
                                                                            TableRow(
                                                                              children: [
                                                                                const Text("Fencer:"),
                                                                                Text(fencer!.name),
                                                                              ],
                                                                            ),
                                                                            TableRow(
                                                                              children: [
                                                                                const Text("When:"),
                                                                                Text(DateFormat('hh:mm a\nEEEE M/d/yy').format(lesson.startTime)),
                                                                              ],
                                                                            ),
                                                                            TableRow(
                                                                              children: [
                                                                                const Text("Coach:"),
                                                                                Text(coach!.fullName),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              context,
                                                                              false),
                                                                          child:
                                                                              const Text("Cancel")),
                                                                      TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              context,
                                                                              true),
                                                                          child:
                                                                              const Text("Register")),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                              if (result ==
                                                                  true) {
                                                                await FirestoreService().addData(
                                                                    path: FirestorePath
                                                                        .lessons(),
                                                                    data: lesson
                                                                        .toMap());

                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(const SnackBar(
                                                                        content:
                                                                            Text("Successfully registered for lesson")));
                                                                Navigator.pop(
                                                                    context);
                                                              }
                                                            },
                                                      child: Text(
                                                        DateFormat('hh:mm a')
                                                            .format(lesson
                                                                .startTime),
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                });
                          },
                        )
                      : Container(),
                );
              } else {
                return SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                );
              }
            },
          ),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    }

    return Consumer(
      builder: (context, watch, child) {
        return watch.watch(userDataProvider).when(
              data: whenData,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (object, stackTrace) => const AuthWrapper(),
            );
      },
    );
  }
}
