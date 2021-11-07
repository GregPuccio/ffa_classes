import 'dart:collection';

import 'package:ffaclasses/src/class_feature/add_class.dart';
import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/class_feature/fclass_details.dart';
import 'package:ffaclasses/src/constants/widgets/multi_select_chip.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:ffaclasses/src/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class FilterableClassList extends StatefulWidget {
  const FilterableClassList({Key? key}) : super(key: key);
  static const routeName = 'classList';

  @override
  _FilterableClassListState createState() => _FilterableClassListState();
}

class _FilterableClassListState extends State<FilterableClassList> {
  List<String> filters = ["All", "Foundation", "Youth", "Mixed", "Advanced"];
  int currentFilter = -1;
  bool calendar = false;

  void setFilter(String val) {
    setState(() {
      switch (val) {
        case "All":
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
      }
    });
  }

  void changeView() {
    setState(() {
      calendar = !calendar;
    });
  }

  late ValueNotifier<List<FClass>> _selectedFClasses;

  DateTime? _selectedDay;

  DateTime _focusedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  LinkedHashMap<DateTime, List<FClass>> fClasses = LinkedHashMap();

  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<FClass> _getFClassesForDay(DateTime? day) {
    return fClasses[day!] ?? [];
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forward Fencing Classes'),
        actions: [
          IconButton(
            onPressed: changeView,
            icon: Icon(calendar ? Icons.list : Icons.calendar_today),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.restorablePushNamed(context, AddClass.routeName);
        },
      ),
      body: calendar
          ? StreamBuilder<Map<DateTime, List<FClass>>>(
              stream: FirestoreService().collectionCalendarStream(
                path: FirestorePath.fClasses(),
                queryBuilder: (query) => query
                    .where('date',
                        isGreaterThanOrEqualTo: _focusedDay
                            .subtract(const Duration(days: 31))
                            .millisecondsSinceEpoch)
                    .where('date',
                        isLessThanOrEqualTo: _focusedDay
                            .add(const Duration(days: 31))
                            .millisecondsSinceEpoch),
                startDate: _focusedDay.subtract(const Duration(days: 31)),
                endDate: _focusedDay.add(const Duration(days: 31)),
                builder: (map, docID) =>
                    FClass.fromMap(map!).copyWith(id: docID),
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  fClasses = LinkedHashMap(
                    equals: isSameDay,
                    // hashCode: getHashCode,
                  )..addAll(snapshot.data!);
                  return Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TableCalendar(
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month'
                            },
                            pageJumpingEnabled: true,
                            firstDay: DateTime.utc(DateTime.now().year - 10),
                            lastDay: DateTime.utc(DateTime.now().year + 20),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDay, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                                _selectedFClasses.value =
                                    _getFClassesForDay(selectedDay);
                              });
                            },
                            calendarFormat: _calendarFormat,
                            onFormatChanged: (format) {
                              setState(() {
                                _calendarFormat = format;
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
                      Expanded(
                        child: ValueListenableBuilder<List<FClass>>(
                          valueListenable: _selectedFClasses,
                          builder: (context, fClasses, _) {
                            return ListView.builder(
                              itemCount: fClasses.length,
                              itemBuilder: (context, index) {
                                final FClass fClass = fClasses[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(fClass.title),
                                    subtitle: Text(fClass.description),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        FClassDetails.routeName,
                                        arguments: ScreenArgs(
                                          fClass: fClass,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              })
          : StreamBuilder<List<FClass>>(
              stream: FirestoreService().collectionStream(
                path: FirestorePath.fClasses(),
                builder: (map, docID) =>
                    FClass.fromMap(map!).copyWith(id: docID),
                queryBuilder: (query) {
                  if (currentFilter != -1) {
                    return query
                        .where('classType', isEqualTo: currentFilter)
                        .orderBy('date');
                  } else {
                    return query.orderBy('date');
                  }
                },
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<FClass> classes = snapshot.data!;
                  return Center(
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 600
                          : null,
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
                            child: ListView.builder(
                              itemCount: classes.length,
                              itemBuilder: (context, index) {
                                FClass fClass = classes[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(
                                        "${fClass.writtenClassType} Class"),
                                    subtitle: Text(
                                      "${fClass.writtenDate} - ${fClass.startTime.format(context)}",
                                    ),
                                    trailing: Text(
                                        "${fClass.fencers.length} fencers"),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        FClassDetails.routeName,
                                        arguments: ScreenArgs(fClass: fClass),
                                      );
                                    },
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Class Deletion'),
                                          content: const Text(
                                              'Would you like to delete this class?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                FirestoreService().deleteData(
                                                    path: FirestorePath.fClass(
                                                        fClass.id));
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
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
            ),
    );
  }
}
