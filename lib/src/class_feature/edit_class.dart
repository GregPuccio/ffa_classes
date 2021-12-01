import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/lists.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/constants/widgets/multi_select_chip.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:flutter/material.dart';
import 'package:time_range/time_range.dart';

class EditClass extends StatefulWidget {
  final ScreenArgs args;
  const EditClass({required this.args, Key? key}) : super(key: key);
  static const routeName = 'editClass';

  @override
  _EditClassState createState() => _EditClassState();
}

class _EditClassState extends State<EditClass> {
  late FClass fClass;
  @override
  void initState() {
    fClass = widget.args.fClass!;
    super.initState();
  }

  void showDateChooser() async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: fClass.date,
      firstDate: DateTime.now().subtract(const Duration(days: 31)),
      lastDate: DateTime.now().add(const Duration(days: 100)),
    );
    if (newDate != null) {
      setState(() {
        fClass = fClass.copyWith(date: newDate.toUtc());
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Class'),
        actions: [
          TextButton(
            onPressed: () {
              List<FClass> classes = [fClass];

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Please Confirm '),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          'Are you sure you would like to update the following:'),
                      Text("${classes.length} ${fClass.title}"),
                      Text("On ${fClass.writtenDate}"),
                      Text(
                          "From ${fClass.startTime.format(context)} to ${fClass.endTime.format(context)}"),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        FirestoreService().updateData(
                          path: FirestorePath.fClass(fClass.id),
                          data: fClass.toMap(),
                        );
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).orientation == Orientation.landscape
              ? 600
              : null,
          child: ListView(
            children: [
              MultiSelectChip(
                itemList: classTypes,
                initialChoices: [fClass.writtenClassType],
                onSelectionChanged: (val) => setState(() {
                  if (val.isNotEmpty) {
                    fClass = fClass.copyWith(classType: val.first);
                  }
                }),
                multi: false,
              ),
              SecondaryButton(
                active: true,
                onPressed: showDateChooser,
                text: fClass.writtenDate,
              ),
              TimeRange(
                fromTitle: const Text('From'),
                toTitle: const Text('To'),
                titlePadding: 20,
                textStyle: Theme.of(context).textTheme.bodyText1,
                activeTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                backgroundColor: Colors.transparent,
                firstTime: const TimeOfDay(hour: 8, minute: 00),
                lastTime: const TimeOfDay(hour: 20, minute: 00),
                initialRange: TimeRangeResult(fClass.startTime, fClass.endTime),
                timeStep: 10,
                timeBlock: 30,
                onRangeCompleted: (range) => setState(() {
                  fClass = fClass.copyWith(
                    startTime: range?.start,
                    endTime: range?.end,
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: fClass.classCost,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  readOnly: true,
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Delete Class"),
                          content: const Text(
                              "Are you sure you would like to delete this class and all of its data? (Fencers registered/paid for, etc.)"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                FirestoreService().deleteData(
                                  path: FirestorePath.fClass(fClass.id),
                                );
                                Navigator.popUntil(
                                    context, ModalRoute.withName('/'));
                              },
                              child: const Text("Delete Class"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),
                          ],
                        );
                      });
                },
                child: Text(
                  "Delete Class",
                  style: Theme.of(context)
                      .textTheme
                      .button!
                      .copyWith(color: Colors.red),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
