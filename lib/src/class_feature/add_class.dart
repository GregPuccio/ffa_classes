import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/constants/lists.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/constants/widgets/multi_select_chip.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:time_range/time_range.dart';
import 'package:intl/intl.dart';

class AddClass extends StatefulWidget {
  final ClassType? classType;
  const AddClass({Key? key, this.classType}) : super(key: key);
  static const routeName = 'addClass';

  @override
  _AddClassState createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {
  late FClass fClass;
  late bool repeat;
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
      classType: widget.classType ?? ClassType.foundation,
      fencers: [],
    );
    repeat = true;
    customClassTypeController = TextEditingController();
    customClassDescriptionController = TextEditingController();
    customMaxNumberController = TextEditingController();
    costController = TextEditingController();
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
    customClassTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Class'),
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
                horizScroll: true,
                itemList: classTypes,
                initialChoices: [classTypes.first],
                onSelectionChanged: (val) => setState(() {
                  if (val.isNotEmpty) {
                    fClass = fClass.copyWith(classType: val.first);
                    if (val.first == classTypes.last) {
                      repeat = false;
                    }
                  }
                }),
                multi: false,
              ),
              if (fClass.classType == fClass.trueClassType(classTypes.last))
                Column(
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
                  ],
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
                  controller: costController,
                  decoration: InputDecoration(
                    labelText: fClass.classCost ?? "Custom class cost",
                    hintText: fClass.classCost,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  readOnly:
                      fClass.classType != fClass.trueClassType(classTypes.last),
                ),
              ),
              if (fClass.classType != fClass.trueClassType(classTypes.last))
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: CheckboxListTile(
                      title: const Text('Repeat for the rest of the month?'),
                      value: repeat,
                      onChanged: (val) {
                        setState(() {
                          repeat = !repeat;
                        });
                      },
                    ),
                  ),
                ),
              InkButton(
                text: 'Create class${repeat ? 'es' : ''}',
                onPressed: () {
                  fClass = fClass.copyWith(
                    customClassTitle: customClassTypeController.text,
                    customClassDescription:
                        customClassDescriptionController.text,
                    customMaxFencers: customMaxNumberController.text,
                    customCost: costController.text,
                  );
                  List<FClass> classes = [fClass];
                  if (repeat &&
                      fClass.classType !=
                          fClass.trueClassType(classTypes.last)) {
                    DateTime newDate = DateTime.utc(fClass.date.year,
                        fClass.date.month, fClass.date.day + 7);
                    while (newDate.month == fClass.date.month) {
                      classes.add(fClass.copyWith(date: newDate));
                      newDate = DateTime.utc(
                          newDate.year, newDate.month, newDate.day + 7);
                    }
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
                          Text(
                              "${classes.length} ${fClass.title.isEmpty ? 'Custom Event' : fClass.title}${classes.length > 1 ? 'es' : ''}"),
                          Text(
                              "On ${classes.length > 1 ? "${DateFormat('EEEE').format(fClass.date)}s" : fClass.writtenDate}"),
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
                            for (var fClass in classes) {
                              FirestoreService().addData(
                                  path: FirestorePath.fClasses(),
                                  data: fClass.toMap());
                            }
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
