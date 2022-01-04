import 'package:ffaclasses/src/constants/lists.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditLessonSchedule extends StatefulWidget {
  final ScreenArgs args;
  const EditLessonSchedule({Key? key, required this.args}) : super(key: key);
  static const routeName = "editLessonSchedule";

  @override
  _EditLessonScheduleState createState() => _EditLessonScheduleState();
}

class _EditLessonScheduleState extends State<EditLessonSchedule> {
  late UserData userData;
  late List<Map<String, Map<String, List<DateTime>>>> availability;

  @override
  void initState() {
    userData = widget.args.userData!;
    availability = userData.availability;
    if (availability.length != daysOfWeek.length) {
      availability = UserData.createAvailability();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FirestoreService().updateData(
            path: FirestorePath.user(userData.id),
            data: {'availability': availability});
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Availability updated")));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Lesson Schedule"),
        ),
        body: Column(
          children: [
            const Divider(),
            ListTile(
              title: Text(userData.fullName,
                  style: Theme.of(context).textTheme.headline6),
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                itemCount: daysOfWeek.length,
                itemBuilder: (context, index) {
                  String day = daysOfWeek[index];
                  List<String> dates = [];

                  dates = availability
                      .firstWhere(
                        (map) => map.containsKey(daysOfWeek[index]),
                      )
                      .entries
                      .firstWhere((element) => element.key == daysOfWeek[index])
                      .value
                      .values
                      .map((e) {
                    String dateString = "";

                    for (var element in e) {
                      if (element != e.first) {
                        dateString = dateString + " - ";
                      }
                      dateString =
                          dateString + DateFormat('hh:mm aa').format(element);
                    }
                    return dateString;
                  }).toList();

                  return Column(
                    children: [
                      const Divider(),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(day),
                            if (availability.isNotEmpty)
                              Builder(builder: (context) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: dates.map((e) => Text(e)).toList(),
                                );
                              }),
                          ],
                        ),
                        onTap: () {
                          showEditDay(context, availability, daysOfWeek[index],
                              setState);
                        },
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.edit),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future showEditDay(
  BuildContext context,
  List<Map<String, Map<String, List<DateTime>>>> availability,
  String dayOfWeek,
  void Function(void Function()) setState,
) {
  Map<String, List<DateTime>> map = availability
      .firstWhere(
        (map) => map.containsKey(dayOfWeek),
      )
      .entries
      .firstWhere((element) => element.key == dayOfWeek)
      .value;
  List<List<DateTime>> dateLists = map.entries.map((e) => e.value).toList();

  void updateAvailability() {
    List<MapEntry<String, List<DateTime>>> entries = [];
    for (int i = 0; i < dateLists.length; i++) {
      entries.add(MapEntry(i.toString(), dateLists[i]));
    }
    Map<String, List<DateTime>> newValue =
        Map<String, List<DateTime>>.fromEntries(entries);
    int index = availability.indexWhere((map) => map.containsKey(dayOfWeek));
    setState(() {
      availability[index][dayOfWeek] = newValue;
    });
  }

  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(builder: (context, newSetState) {
      return AlertDialog(
        title: Text("Edit $dayOfWeek Schedule"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: dateLists.map((dates) {
                return Column(
                  children: [
                    if (dates != dateLists.first) const Divider(),
                    Row(
                      children: [
                        TextButton(
                          child: Text(
                            DateFormat('hh:mm aa').format(dates.first),
                          ),
                          onPressed: () async {
                            TimeOfDay? newTOD = await showTimePicker(
                                context: context,
                                initialTime:
                                    TimeOfDay.fromDateTime(dates.first));
                            if (newTOD != null) {
                              newSetState(() {
                                dates.first = DateTime(
                                    dates.first.year,
                                    dates.first.month,
                                    dates.first.day,
                                    newTOD.hour,
                                    newTOD.minute);
                              });
                              updateAvailability();
                            }
                          },
                        ),
                        const Text("-"),
                        TextButton(
                          child: Text(
                            DateFormat('hh:mm aa').format(dates.last),
                          ),
                          onPressed: () async {
                            TimeOfDay? newTOD = await showTimePicker(
                                context: context,
                                initialTime:
                                    TimeOfDay.fromDateTime(dates.last));
                            if (newTOD != null) {
                              newSetState(() {
                                dates.last = DateTime(
                                    dates.last.year,
                                    dates.last.month,
                                    dates.last.day,
                                    newTOD.hour,
                                    newTOD.minute);
                              });
                              updateAvailability();
                            }
                          },
                        ),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text("Delete?"),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("Cancel")),
                                          TextButton(
                                              onPressed: () {
                                                newSetState(() {
                                                  dateLists.remove(dates);
                                                });
                                                updateAvailability();
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Delete")),
                                        ],
                                      ));
                            },
                            icon: const Icon(Icons.remove_circle))
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
            TextButton(
                onPressed: () {
                  newSetState(() {
                    dateLists.add(dateLists.isNotEmpty
                        ? [
                            dateLists.last.last,
                            dateLists.last.last.add(const Duration(hours: 1)),
                          ]
                        : [
                            DateTime.now(),
                            DateTime.now().add(const Duration(hours: 1)),
                          ]);
                  });
                  updateAvailability();
                },
                child: const Text("Add Additional Hours"))
          ],
        ),
      );
    }),
  );
}
