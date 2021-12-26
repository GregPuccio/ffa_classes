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
  const AddClass({Key? key}) : super(key: key);
  static const routeName = 'addClass';

  @override
  _AddClassState createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {
  late FClass fClass;
  late bool repeat;
  @override
  void initState() {
    fClass = FClass(
      id: 'id',
      date: DateTime.utc(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      startTime: const TimeOfDay(hour: 16, minute: 30),
      endTime: const TimeOfDay(hour: 18, minute: 00),
      classType: ClassType.foundation,
      fencers: [],
      userIDs: [],
    );
    repeat = true;

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
        title: const Text('Add Class'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              MultiSelectChip(
                itemList: classTypes,
                initialChoices: [classTypes.first],
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
                  List<FClass> classes = [fClass];
                  if (repeat) {
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
                              "${classes.length} ${fClass.title}${classes.length > 1 ? 'es' : ''}"),
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
                          child: const Text("CANCEL"),
                        ),
                        TextButton(
                          onPressed: () {
                            for (var fClass in classes) {
                              FirestoreService().addData(
                                  path: FirestorePath.fClasses(),
                                  data: fClass.toMap());
                            }
                            Navigator.popUntil(
                                context, ModalRoute.withName('/'));
                          },
                          child: const Text("CONFIRM"),
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
