import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/camp_feature/camp_details.dart';
import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/class_feature/fclass_details.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/constants/widgets/multi_select_chip.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/strip_coaching_feature/strip_coaching_details.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ClassListView extends StatefulWidget {
  const ClassListView({Key? key}) : super(key: key);

  @override
  State<ClassListView> createState() => _ClassListViewState();
}

class _ClassListViewState extends State<ClassListView> {
  List<String> filters = [
    "All",
    "Registered",
    "Foundation",
    "Youth",
    "Mixed",
    "Advanced",
    "Camps",
    "Strip Coaching",
  ];

  int currentFilter = -2;

  void setFilter(String val) {
    if (val != filters[currentFilter + 2]) {
      setState(() {
        switch (val) {
          case "All":
            currentFilter = -2;
            break;
          case "Registered":
            currentFilter = -1;
            break;
          case "Foundation":
            currentFilter = 0;
            break;
          case "Youth":
            currentFilter = 1;
            break;
          case "Mixed":
            currentFilter = 2;
            break;
          case "Advanced":
            currentFilter = 3;
            break;
          case "Camps":
            currentFilter = 4;
            break;
          case "Strip Coaching":
            currentFilter = 5;
            break;
        }
      });
    } else {
      setState(() {
        _needScroll = true;
      });
    }
  }

  bool _needScroll = true;
  final AutoScrollController _scrollController =
      AutoScrollController(suggestedRowHeight: 125);

  void _scrollToDate() {
    int todayNumber = DateTime.now().day - 1;
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
        return StreamBuilder<List<FClass>>(
          stream: FirestoreService().collectionStream(
            path: FirestorePath.fClasses(),
            builder: (map, docID) => FClass.fromMap(map!).copyWith(id: docID),
            queryBuilder: (query) {
              DateTime now = DateTime.now();
              DateTime thisMonth = DateTime.utc(now.year, now.month);
              if (currentFilter >= 0) {
                return query
                    .where('classType', isEqualTo: currentFilter)
                    .orderBy('date')
                    .where('date',
                        isGreaterThanOrEqualTo:
                            thisMonth.millisecondsSinceEpoch);
              } else {
                return query.orderBy('date').where('date',
                    isGreaterThanOrEqualTo: thisMonth.millisecondsSinceEpoch);
              }
            },
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (_needScroll) {
                WidgetsBinding.instance!
                    .addPostFrameCallback((_) => _scrollToDate());
                _needScroll = false;
              }

              List<FClass> classes = snapshot.data!;
              if (currentFilter == -1) {
                if (userData.admin) {
                  classes.removeWhere(
                      (fClass) => !fClass.coaches.contains(userData.toCoach()));
                } else {
                  classes.removeWhere(
                      (fClass) => !userData.isFencerInList(fClass.fencers));
                }
              }
              classes.sort();
              List<List<FClass>> classesByDate =
                  FClass.sortClassesByDate(classes);
              return Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      MultiSelectChip(
                        initialChoices: [filters.first],
                        itemList: filters,
                        onSelectionChanged: (val) => setFilter(val.first),
                        multi: false,
                        horizScroll: true,
                      ),
                      Flexible(
                        child: CustomScrollView(
                          controller: _scrollController,
                          restorationId: 'class_list',
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  List<FClass> fClasses = classesByDate[index];
                                  return AutoScrollTag(
                                    key: ValueKey(index),
                                    controller: _scrollController,
                                    index: index,
                                    child: fClasses.isNotEmpty
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
                                                fClasses.first.writtenDate,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            content: Column(
                                              children: fClasses.map((fClass) {
                                                return Column(
                                                  children: [
                                                    if (fClass !=
                                                        fClasses.first)
                                                      const Divider(
                                                        indent: 20,
                                                        endIndent: 20,
                                                        height: 1,
                                                      ),
                                                    ListTile(
                                                      title: Text(fClass.title),
                                                      subtitle: Text(
                                                        fClass.fencers.length ==
                                                                1
                                                            ? "1 fencer"
                                                            : "${fClass.fencers.length} fencers",
                                                      ),
                                                      trailing: fClass
                                                                  .classType !=
                                                              ClassType
                                                                  .stripCoaching
                                                          ? Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(fClass
                                                                    .startTime
                                                                    .format(
                                                                        context)),
                                                                Text(fClass
                                                                    .endTime
                                                                    .format(
                                                                        context)),
                                                              ],
                                                            )
                                                          : null,
                                                      onTap: () {
                                                        String route;
                                                        if (fClass.classType ==
                                                            ClassType.camp) {
                                                          route = CampDetails
                                                              .routeName;
                                                        } else if (fClass
                                                                .classType ==
                                                            ClassType
                                                                .stripCoaching) {
                                                          route =
                                                              StripCoachingDetails
                                                                  .routeName;
                                                        } else {
                                                          route = FClassDetails
                                                              .routeName;
                                                        }
                                                        Navigator
                                                            .restorablePushNamed(
                                                          context,
                                                          '$route/${fClass.id}',
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
                                childCount: classesByDate.length,
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
