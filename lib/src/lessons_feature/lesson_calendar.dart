import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/coach_feature/coach.dart';
import 'package:ffaclasses/src/constants/lists.dart';
import 'package:ffaclasses/src/constants/widgets/calendar_lesson_event_text.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/lessons_feature/edit_lesson.dart';
import 'package:ffaclasses/src/lessons_feature/lesson.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';

class LessonCalendarView extends StatefulWidget {
  const LessonCalendarView({Key? key}) : super(key: key);

  @override
  _LessonCalendarViewState createState() => _LessonCalendarViewState();
}

class _LessonCalendarViewState extends State<LessonCalendarView> {
  Coach? coach;
  late WeekViewController weekViewController;
  final AutoScrollController _scrollController =
      AutoScrollController(suggestedRowHeight: 125);
  bool calendar = true;

  @override
  void initState() {
    weekViewController = WeekViewController();
    super.initState();
  }

  @override
  void dispose() {
    weekViewController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return Column(
          children: [
            ListTile(
              title: Text(coach?.fullName ?? userData.fullName,
                  style: Theme.of(context).textTheme.headline6),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Employee"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: coaches
                            .map((e) => TextButton(
                                  child: Text(e.fullName),
                                  onPressed: () {
                                    setState(() {
                                      coach = e;
                                    });
                                    Navigator.pop(context);
                                  },
                                ))
                            .toList(),
                      ),
                    );
                  },
                );
              },
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    calendar = !calendar;
                  });
                },
                icon: Icon(calendar ? Icons.list : Icons.event),
              ),
            ),
            StreamBuilder<List<Lesson>>(
              stream: FirestoreService().collectionStream(
                path: FirestorePath.lessons(),
                builder: (map, docID) =>
                    Lesson.fromMap(map!).copyWith(id: docID),
                queryBuilder: (query) => query.where('coach.id',
                    isEqualTo: coach?.id ?? userData.id),
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Lesson> lessons = snapshot.data!;
                  lessons.sort((a, b) => a.startTime.compareTo(b.startTime));
                  List<List<Lesson>> lessonsByDate =
                      Lesson.sortClassesByDate(lessons);
                  return calendar
                      ? Flexible(
                          child: WeekView.builder(
                            style: WeekViewStyle(
                              dayViewSeparatorWidth: 1,
                              dayViewWidth:
                                  (MediaQuery.of(context).size.width - 60) / 7,
                              dayViewSeparatorColor:
                                  Theme.of(context).colorScheme.onBackground,
                            ),
                            minimumTime: const HourMinute(hour: 7),
                            maximumTime: const HourMinute(hour: 22),
                            controller: weekViewController,
                            dateCount: 100,
                            events: lessons
                                .map(
                                  (e) => FlutterWeekViewEvent(
                                      title: e.fencer.name,
                                      description: e.type,
                                      start: e.startTime,
                                      end: e.endTime,
                                      textStyle:
                                          Theme.of(context).textTheme.caption,
                                      padding: const EdgeInsets.all(5),
                                      eventTextBuilder: defaultEventTextBuilder,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          EditLesson.routeName,
                                          arguments: ScreenArgs(lesson: e),
                                        );
                                      }),
                                )
                                .toList(),
                            dateCreator: (index) =>
                                DateTime(2022, 1, 2 + index),
                            dayBarStyleBuilder: (date) =>
                                DayBarStyle.fromDate(date: date).copyWith(
                              color: Theme.of(context).colorScheme.surface,
                              textStyle: Theme.of(context).textTheme.bodyText2,
                              dateFormatter: (year, month, day) =>
                                  DateFormat('MMM\n').format(date) +
                                  DateFormat('E').format(date).substring(0, 1) +
                                  DateFormat(' d').format(date),
                              textAlignment: Alignment.center,
                            ),
                            dayViewStyleBuilder: (date) =>
                                DayViewStyle.fromDate(date: date).copyWith(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(126),
                              backgroundRulesColor:
                                  Theme.of(context).colorScheme.onBackground,
                              currentTimeRuleColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                            hoursColumnStyle: HoursColumnStyle(
                              color: Theme.of(context).colorScheme.surface,
                              width: 55,
                              timeFormatter: (time) => DateFormat('h a')
                                  .format(time.atDate(DateTime.now())),
                              textStyle: Theme.of(context).textTheme.subtitle2,
                            ),
                            onHoursColumnTappedDown: (hourMinute) => showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("${hourMinute.hour}:00"),
                                  );
                                }),
                          ),
                        )
                      : Flexible(
                          child: CustomScrollView(
                            controller: _scrollController,
                            restorationId: 'lesson_list',
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    List<Lesson> fLessons =
                                        lessonsByDate[index];
                                    return AutoScrollTag(
                                      key: ValueKey(index),
                                      controller: _scrollController,
                                      index: index,
                                      child: fLessons.isNotEmpty
                                          ? StickyHeader(
                                              header: Container(
                                                height: 50.0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  DateFormat('EEEE M/d/y')
                                                      .format(fLessons
                                                          .first.startTime),
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              content: Column(
                                                children:
                                                    fLessons.map((fLesson) {
                                                  return Column(
                                                    children: [
                                                      if (fLesson !=
                                                          fLessons.first)
                                                        const Divider(
                                                          indent: 20,
                                                          endIndent: 20,
                                                          height: 1,
                                                        ),
                                                      ListTile(
                                                        title: Text(fLesson
                                                            .fencer.firstName),
                                                        subtitle: Text(
                                                            "${fLesson.type} with Coach ${fLesson.coach.firstName}"),
                                                        trailing: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(DateFormat(
                                                                    'h:mm a')
                                                                .format(fLesson
                                                                    .startTime)),
                                                            Text(DateFormat(
                                                                    'h:mm a')
                                                                .format(fLesson
                                                                    .endTime)),
                                                          ],
                                                        ),
                                                        onTap: () {
                                                          Navigator.pushNamed(
                                                            context,
                                                            EditLesson
                                                                .routeName,
                                                            arguments:
                                                                ScreenArgs(
                                                              lesson: fLesson,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            )
                                          : Container(),
                                    );
                                  },
                                  childCount: lessonsByDate.length,
                                ),
                              ),
                            ],
                          ),
                        );
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
