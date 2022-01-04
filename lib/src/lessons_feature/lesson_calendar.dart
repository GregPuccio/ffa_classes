import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/coach_feature/coach.dart';
import 'package:ffaclasses/src/constants/links.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/lessons_feature/lesson.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonCalendarView extends StatefulWidget {
  const LessonCalendarView({Key? key}) : super(key: key);

  @override
  _LessonCalendarViewState createState() => _LessonCalendarViewState();
}

class _LessonCalendarViewState extends State<LessonCalendarView> {
  Coach? coach;
  late WeekViewController weekViewController;

  @override
  void initState() {
    weekViewController = WeekViewController();
    super.initState();
  }

  @override
  void dispose() {
    weekViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return Column(
          children: [
            ListTile(
              title: Text(
                "Private Lessons (on Square)",
                style: Theme.of(context).textTheme.headline6,
              ),
              trailing: const Icon(Icons.launch),
              onTap: () => launch(squareLessonsLink),
            ),
            if (!userData.admin)
              Flexible(
                child: Center(
                  child: Text(
                    "Private Lessons in the app\nare currently under construction",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
            if (userData.admin)
              StreamBuilder<UserData>(
                stream: FirestoreService().documentStream(
                  path: FirestorePath.user(coach?.id ?? userData.id),
                  builder: (map, docID) =>
                      UserData.fromMap(map!).copyWith(id: docID),
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // Coach coach = snapshot.data!.toCoach();

                    return StreamBuilder<List<Lesson>>(
                        stream: FirestoreService().collectionStream(
                          path: FirestorePath.lessons(),
                          builder: (map, docID) =>
                              Lesson.fromMap(map!).copyWith(id: docID),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Lesson> lessons = snapshot.data!;
                            return Flexible(
                              child: WeekView.builder(
                                style: WeekViewStyle(
                                  dayViewSeparatorWidth: 1,
                                  dayViewWidth:
                                      (MediaQuery.of(context).size.width - 80) /
                                          7,
                                  dayViewSeparatorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                                minimumTime: const HourMinute(hour: 7),
                                maximumTime: const HourMinute(hour: 22),
                                controller: weekViewController,
                                dateCount: 100,
                                events: lessons
                                    .map((e) => FlutterWeekViewEvent(
                                        title: e.fencer.name,
                                        description: e.lessonType.toString(),
                                        start: e.startTime,
                                        end: e.endTime))
                                    .toList(),
                                dateCreator: (index) =>
                                    DateTime(2022, 1, 2 + index),
                                dayBarStyleBuilder: (date) =>
                                    DayBarStyle.fromDate(date: date).copyWith(
                                  color: Theme.of(context).colorScheme.surface,
                                  textStyle:
                                      Theme.of(context).textTheme.bodyText2,
                                  dateFormatter: (year, month, day) =>
                                      DateFormat('E')
                                          .format(date)
                                          .substring(0, 1) +
                                      DateFormat(' d').format(date),
                                ),
                                dayViewStyleBuilder: (date) =>
                                    DayViewStyle.fromDate(date: date).copyWith(
                                  backgroundColor: DateTime(date.year,
                                              date.month, date.day) ==
                                          DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day)
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryVariant
                                      : Theme.of(context).colorScheme.primary,
                                  backgroundRulesColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  currentTimeRuleColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                                hoursColumnStyle: HoursColumnStyle(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 55,
                                  timeFormatter: (time) => DateFormat('h a')
                                      .format(time.atDate(DateTime.now())),
                                  textStyle:
                                      Theme.of(context).textTheme.subtitle2,
                                ),
                                onHoursColumnTappedDown: (hourMinute) =>
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title:
                                                Text("${hourMinute.hour}:00"),
                                          );
                                        }),
                              ),
                            );
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        });
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
          ],
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
