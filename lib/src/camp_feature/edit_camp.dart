import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:flutter/material.dart';
import 'package:time_range/time_range.dart';

class EditCamp extends StatefulWidget {
  final ScreenArgs args;
  const EditCamp({required this.args, Key? key}) : super(key: key);
  static const routeName = "editCamp";

  @override
  _EditCampState createState() => _EditCampState();
}

class _EditCampState extends State<EditCamp> {
  late TextEditingController customClassTitleController;
  late TextEditingController customClassDescriptionController;
  late TextEditingController customMaxNumberController;
  late TextEditingController regRateController;
  late TextEditingController unlimRateController;
  late TextEditingController regDiscountController;
  late TextEditingController unlimDiscountController;
  late FClass fClass;

  @override
  void initState() {
    fClass = widget.args.fClass!;
    customClassTitleController =
        TextEditingController(text: fClass.customClassTitle);
    customClassDescriptionController =
        TextEditingController(text: fClass.customClassDescription);
    customMaxNumberController =
        TextEditingController(text: fClass.customMaxFencers);
    regRateController = TextEditingController(text: fClass.customRegRate);
    regDiscountController =
        TextEditingController(text: fClass.customRegDiscount);
    unlimRateController = TextEditingController(text: fClass.customUnlimRate);
    unlimDiscountController =
        TextEditingController(text: fClass.customUnlimDiscount);
    super.initState();
  }

  @override
  void dispose() {
    customClassTitleController.dispose();
    customClassDescriptionController.dispose();
    customMaxNumberController.dispose();
    regRateController.dispose();
    unlimRateController.dispose();
    regDiscountController.dispose();
    unlimDiscountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void showDateChooser() async {
      DateTimeRange? newRange = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(
            start: fClass.date, end: fClass.endDate ?? fClass.date),
        firstDate: DateTime.now().subtract(const Duration(days: 31)),
        lastDate: DateTime.now().add(const Duration(days: 100)),
      );
      if (newRange != null) {
        setState(() {
          fClass = fClass.copyWith(
              date: newRange.start.toUtc(), endDate: newRange.end.toUtc());
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Edit ${fClass.classType == ClassType.camp ? "Camp" : "Class"}"),
        actions: [
          TextButton(
            onPressed: () {
              fClass = fClass.copyWith(
                customClassTitle: customClassTitleController.text,
                customClassDescription: customClassDescriptionController.text,
                customMaxFencers: customMaxNumberController.text,
                customRegRate: regRateController.text,
                customRegDiscount: regDiscountController.text,
                customUnlimRate: unlimRateController.text,
                customUnlimDiscount: unlimDiscountController.text,
              );
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Please Confirm Information'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          'Are you sure you would like to update the following:'),
                      Text(
                          fClass.title.isEmpty ? 'Custom Event' : fClass.title),
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
                        FirestoreService().updateData(
                            path: FirestorePath.fClass(fClass.id),
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
            child: Text(
              "Save",
              style: Theme.of(context)
                  .textTheme
                  .button!
                  .copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
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
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: customClassTitleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: customClassDescriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
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
                timeBlock: 10,
                onRangeCompleted: (range) => setState(() {
                  fClass = fClass.copyWith(
                    startTime: range?.start,
                    endTime: range?.end,
                  );
                }),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: regRateController,
                        decoration: const InputDecoration(
                          labelText: "Reg Rate/Day",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    ),
                    Flexible(
                      child: TextField(
                        controller: regDiscountController,
                        decoration: const InputDecoration(
                          labelText: "Discount",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.remove),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: unlimRateController,
                        decoration: const InputDecoration(
                          labelText: "Unlim Rate/Day",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    ),
                    Flexible(
                      child: TextField(
                        controller: unlimDiscountController,
                        decoration: const InputDecoration(
                          labelText: "Discount",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.remove),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Delete Camp"),
                          content: const Text(
                              "Are you sure you would like to delete this camp and all of its data? (Fencers registered/paid for, etc.)"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                FirestoreService().deleteData(
                                  path: FirestorePath.fClass(fClass.id),
                                );
                                Navigator.popUntil(
                                    context, ModalRoute.withName('/'));
                              },
                              child: const Text("Delete Camp"),
                            ),
                            TextButton(
                              onPressed: () {
                                FirestoreService().deleteData(
                                  path: FirestorePath.fClass(fClass.id),
                                );
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),
                          ],
                        );
                      });
                },
                child: Text(
                  "Delete Camp",
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
