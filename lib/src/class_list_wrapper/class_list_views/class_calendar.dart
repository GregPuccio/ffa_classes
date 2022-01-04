import 'dart:collection';

import 'package:ffaclasses/src/camp_feature/camp_details.dart';
import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/class_feature/fclass_details.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/strip_coaching_feature/strip_coaching_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ClassCalendarView extends StatefulWidget {
  const ClassCalendarView({Key? key}) : super(key: key);

  @override
  _ClassCalendarViewState createState() => _ClassCalendarViewState();
}

class _ClassCalendarViewState extends State<ClassCalendarView> {
  late ValueNotifier<List<FClass>> _selectedFClasses;

  DateTime? _selectedDay;

  DateTime _focusedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  LinkedHashMap<DateTime, List<FClass>> fClasses = LinkedHashMap();

  List<FClass> _getFClassesForDay(DateTime? day) {
    return fClasses[day!] ?? [];
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    _selectedDay = _focusedDay;
    _selectedFClasses = ValueNotifier(_getFClassesForDay(_selectedDay));
    super.initState();
  }

  @override
  void dispose() {
    _selectedFClasses.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<DateTime, List<FClass>>>(
      stream: FirestoreService().collectionCalendarStream<FClass>(
        path: FirestorePath.fClasses(),
        queryBuilder: (query) => query
            .where('date',
                isGreaterThanOrEqualTo: DateTime.utc(_focusedDay.year,
                        _focusedDay.month, _focusedDay.day - 31)
                    .millisecondsSinceEpoch)
            .where('date',
                isLessThanOrEqualTo: DateTime.utc(_focusedDay.year,
                        _focusedDay.month, _focusedDay.day + 31)
                    .millisecondsSinceEpoch),
        startDate: DateTime.utc(
            _focusedDay.year, _focusedDay.month, _focusedDay.day - 31),
        endDate: DateTime.utc(
            _focusedDay.year, _focusedDay.month, _focusedDay.day + 31),
        builder: (map, docID) => FClass.fromMap(map!).copyWith(id: docID),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          fClasses = LinkedHashMap(
            equals: isSameDay,
            hashCode: getHashCode,
          )..addAll(snapshot.data!);

          bool portrait =
              MediaQuery.of(context).orientation == Orientation.portrait;
          List<Widget> children = [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month'
                  },
                  pageJumpingEnabled: true,
                  firstDay: DateTime.utc(DateTime.now().year - 1),
                  lastDay: DateTime.utc(DateTime.now().year + 20),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedFClasses.value = _getFClassesForDay(selectedDay);
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (day) {
                    return _getFClassesForDay(day);
                  },
                ),
              ),
            ),
            Flexible(
              child: ValueListenableBuilder<List<FClass>>(
                valueListenable: _selectedFClasses,
                builder: (context, fClasses, _) {
                  fClasses.sort();
                  return ListView.builder(
                    itemCount: fClasses.length,
                    itemBuilder: (context, index) {
                      final FClass fClass = fClasses[index];
                      return Card(
                        child: ListTile(
                          title: Text(fClass.title),
                          subtitle: Text(
                            "${fClass.fencers.length} fencers",
                          ),
                          trailing: fClass.classType != ClassType.stripCoaching
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(fClass.startTime.format(context)),
                                    Text(fClass.endTime.format(context)),
                                  ],
                                )
                              : null,
                          onTap: () {
                            String route;
                            if (fClass.classType == ClassType.camp) {
                              route = CampDetails.routeName;
                            } else if (fClass.classType ==
                                ClassType.stripCoaching) {
                              route = StripCoachingDetails.routeName;
                            } else {
                              route = FClassDetails.routeName;
                            }
                            Navigator.restorablePushNamed(
                              context,
                              '$route/${fClass.id}',
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ];
          return Center(
            child: Container(
              alignment: Alignment.topCenter,
              width: 1000,
              child: portrait
                  ? Column(
                      children: children,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(child: children[0]),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Classes for ${DateFormat.yMEd().format(_selectedDay!)}",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                              children[1],
                            ],
                          ),
                        )
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
}
