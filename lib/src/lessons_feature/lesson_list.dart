import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/lessons_feature/lesson.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class LessonsList extends StatefulWidget {
  const LessonsList({Key? key}) : super(key: key);

  @override
  State<LessonsList> createState() => _LessonsListState();
}

class _LessonsListState extends State<LessonsList> {
  bool _needScroll = true;

  final AutoScrollController _scrollController =
      AutoScrollController(suggestedRowHeight: 125);

  void _scrollToDate() {
    int todayNumber = DateTime.now().day;
    _scrollController.scrollToIndex(
      todayNumber,
      preferPosition: AutoScrollPosition.begin,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        if (!userData.admin) {
          return const Center(
            child: Text("Coming Soon!"),
          );
        } else {
          return StreamBuilder<List<Lesson>>(
            stream: FirestoreService().collectionStream(
              path: FirestorePath.lessons(),
              builder: (map, docID) => Lesson.fromMap(map!).copyWith(id: docID),
              queryBuilder: (query) {
                DateTime now = DateTime.now();
                DateTime thisMonth = DateTime.utc(now.year, now.month);
                // if (currentFilter >= 0) {
                //   return query
                //       .where('classType', isEqualTo: currentFilter)
                //       .orderBy('date')
                //       .where('date',
                //           isGreaterThanOrEqualTo:
                //               thisMonth.millisecondsSinceEpoch);
                // } else {
                return query.orderBy('startTime').where('startTime',
                    isGreaterThanOrEqualTo: thisMonth.millisecondsSinceEpoch);
                // }
              },
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (_needScroll) {
                  WidgetsBinding.instance!
                      .addPostFrameCallback((_) => _scrollToDate());
                  _needScroll = false;
                }

                List<Lesson> lessons = snapshot.data!;
                // if (currentFilter == -1) {
                //   if (userData.admin) {
                //     classes.removeWhere(
                //         (fClass) => !fClass.coaches.contains(userData.toCoach()));
                //   } else {
                //     classes.removeWhere(
                //         (fClass) => !userData.isFencerInList(fClass.fencers));
                //   }
                // }
                lessons.sort();
                List<List<Lesson>> lessonsByDate = [];
                // Lesson.sortClassesByDate(classes);
                return Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        // MultiSelectChip(
                        //   initialChoices: [filters.first],
                        //   itemList: filters,
                        //   onSelectionChanged: (val) => setFilter(val.first),
                        //   multi: false,
                        //   horizScroll: true,
                        // ),
                        Flexible(
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
                                                  fLessons.first.startTime
                                                      .toString(),
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
                                                            .lessonType
                                                            .toString()),
                                                        subtitle: Text(
                                                          fLesson.startTime
                                                              .toString(),
                                                        ),
                                                        trailing: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(fLesson
                                                                .startTime
                                                                .toString()),
                                                            Text(fLesson.endTime
                                                                .toString()),
                                                          ],
                                                        ),
                                                        onTap: () {
                                                          // Navigator
                                                          //     .restorablePushNamed(
                                                          //   context,
                                                          //   '${FClassDetails.routeName}/${fClass.id}',
                                                          // );
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
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        }
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
