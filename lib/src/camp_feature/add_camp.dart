import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:time_range/time_range.dart';

class AddCamp extends StatefulWidget {
  const AddCamp({Key? key}) : super(key: key);
  static const routeName = 'addCamp';

  @override
  _AddCampState createState() => _AddCampState();
}

class _AddCampState extends State<AddCamp> {
  late FClass fClass;
  late TextEditingController customClassTypeController;
  late TextEditingController customClassDescriptionController;
  late TextEditingController customMaxNumberController;
  late TextEditingController costController;
  @override
  void initState() {
    fClass = FClass(
      id: 'id',
      date: DateTime.utc(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      startTime: const TimeOfDay(hour: 16, minute: 30),
      endTime: const TimeOfDay(hour: 18, minute: 00),
      classType: ClassType.camp,
      fencers: [],
    );
    customClassTypeController = TextEditingController();
    customClassDescriptionController = TextEditingController();
    customMaxNumberController = TextEditingController();
    costController = TextEditingController();
    super.initState();
  }

  void showDateChooser() async {
    DateTimeRange? newRange = await showDateRangePicker(
      context: context,
      initialDateRange:
          DateTimeRange(start: fClass.date, end: fClass.endDate ?? fClass.date),
      firstDate: DateTime.now().subtract(const Duration(days: 31)),
      lastDate: DateTime.now().add(const Duration(days: 100)),
    );
    if (newRange != null) {
      setState(() {
        fClass = fClass.copyWith(
            date: newRange.start.toUtc(), endDate: newRange.end.toUtc());
      });
    }
    // DateTime? newDate = await showDatePicker(
    //   context: context,
    //   initialDate: fClass.date,
    //   firstDate: DateTime.now().subtract(const Duration(days: 31)),
    //   lastDate: DateTime.now().add(const Duration(days: 100)),
    // );
    // if (newDate != null) {
    //   setState(() {
    //     fClass = fClass.copyWith(date: newDate.toUtc());
    //   });
    // }
  }

  @override
  void dispose() {
    customClassTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add A Camp'),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).orientation == Orientation.landscape
              ? 600
              : null,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: customClassTypeController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: customClassDescriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: customMaxNumberController,
                  decoration: const InputDecoration(
                    labelText: "Maximum number of fencers",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SecondaryButton(
                active: true,
                onPressed: showDateChooser,
                text: fClass.dateRange,
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
                  controller: costController,
                  decoration: InputDecoration(
                    labelText: "Camp cost",
                    hintText: fClass.classCost,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                ),
              ),
              InkButton(
                text: 'Create camp',
                onPressed: () {
                  fClass = fClass.copyWith(
                    customClassTitle: customClassTypeController.text,
                    customClassDescription:
                        customClassDescriptionController.text,
                    customMaxFencers: customMaxNumberController.text,
                    customCost: costController.text,
                  );
                  List<FClass> classes = [fClass];
                  if (fClass.endDate != null && fClass.date != fClass.endDate) {
                    DateTime newDate = DateTime.utc(fClass.date.year,
                        fClass.date.month, fClass.date.day + 1);
                    while (newDate.isBefore(fClass.endDate!)) {
                      classes.add(fClass.copyWith(date: newDate));
                      newDate = DateTime.utc(
                          newDate.year, newDate.month, newDate.day + 1);
                    }
                    fClass.copyWith(campDays: classes);
                  }
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Please Confirm Information'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                              'Are you sure you would like to create the following:'),
                          Text(fClass.title.isEmpty
                              ? 'Custom Event'
                              : fClass.title),
                          Text(fClass.dateRange),
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
                            FirestoreService().addData(
                                path: FirestorePath.fClasses(),
                                data: fClass.toMap());
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text("Confirm"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
