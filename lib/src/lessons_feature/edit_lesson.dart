import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/lessons_feature/lesson.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EditLesson extends StatefulWidget {
  final ScreenArgs args;
  const EditLesson({Key? key, required this.args}) : super(key: key);
  static const routeName = 'editLesson';

  @override
  _EditLessonState createState() => _EditLessonState();
}

class _EditLessonState extends State<EditLesson> {
  late Lesson lesson;
  bool changed = false;

  @override
  void initState() {
    lesson = widget.args.lesson!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Edit Lesson"),
            actions: [
              if (userData.admin)
                TextButton(
                    onPressed: () async {
                      if (changed) {
                        await FirestoreService().updateData(
                            path: FirestorePath.lesson(lesson.id),
                            data: {
                              'startTime':
                                  lesson.startTime.millisecondsSinceEpoch,
                              'endTime': lesson.endTime.millisecondsSinceEpoch,
                            });
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lesson updated")));
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Save",
                      style: Theme.of(context)
                          .textTheme
                          .button!
                          .copyWith(color: Colors.white),
                    )),
            ],
          ),
          body: ListView(
            children: [
              ListTile(
                title: Text(lesson.fencer.name),
                subtitle: Text(lesson.fencer.emailAddress),
              ),
              const Divider(),
              ListTile(
                title: const Text("Date & Time"),
                trailing: userData.admin
                    ? TextButton(
                        child: Text(DateFormat('EE, MMM d, h:mm a')
                            .format(lesson.startTime)),
                        onPressed: () async {
                          TimeOfDay? newTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                  hour: lesson.startTime.hour,
                                  minute: lesson.startTime.minute));
                          if (newTime != null) {
                            DateTime startTime = DateTime(
                                lesson.startTime.year,
                                lesson.startTime.month,
                                lesson.startTime.day,
                                newTime.hour,
                                newTime.minute);
                            DateTime endTime = DateTime(
                                lesson.startTime.year,
                                lesson.startTime.month,
                                lesson.startTime.day,
                                newTime.hour,
                                newTime.minute + (lesson.lengthInMinutes));
                            setState(() {
                              lesson = lesson.copyWith(
                                  startTime: startTime, endTime: endTime);
                              changed = true;
                            });
                          }
                        },
                      )
                    : Text(DateFormat('EE, MMM d, h:mm a')
                        .format(lesson.startTime)),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Duration: ${lesson.length}. Ends at ${DateFormat('h:mm a').format(lesson.endTime)}",
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(lesson.type),
                subtitle: Text(lesson.description),
              ),
              const Divider(),
              SecondaryButton(
                text: "Cancel Lesson",
                onPressed: () async {
                  bool? result = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Cancel Lesson"),
                          content: const Text(
                              "Please confirm that you would like to cancel this lesson."),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text("Cancel Lesson")),
                          ],
                        );
                      });
                  if (result == true) {
                    await FirestoreService()
                        .deleteData(path: FirestorePath.lesson(lesson.id));
                    Navigator.pop(context);
                  }
                },
              ),
            ],
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
