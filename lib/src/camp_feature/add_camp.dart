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
  late TextEditingController customCampTitleController;
  late TextEditingController customClassDescriptionController;
  late TextEditingController customMaxNumberController;
  late TextEditingController regRateController;
  late TextEditingController unlimRateController;
  late TextEditingController regDiscountController;
  late TextEditingController unlimDiscountController;

  @override
  void initState() {
    fClass = FClass.create(classType: ClassType.camp);
    customCampTitleController = TextEditingController();
    customClassDescriptionController = TextEditingController();
    customMaxNumberController = TextEditingController();
    regRateController = TextEditingController();
    unlimRateController = TextEditingController();
    regDiscountController = TextEditingController();
    unlimDiscountController = TextEditingController();
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
  }

  @override
  void dispose() {
    customCampTitleController.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add A Camp'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: customCampTitleController,
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
                    const SizedBox(width: 5),
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
                    const SizedBox(width: 5),
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
              InkButton(
                text: 'Create camp',
                onPressed: () {
                  fClass = fClass.copyWith(
                    customClassTitle: customCampTitleController.text,
                    customClassDescription:
                        customClassDescriptionController.text,
                    customMaxFencers: customMaxNumberController.text,
                    customRegRate: regRateController.text,
                    customRegDiscount: regDiscountController.text,
                    customUnlimRate: unlimRateController.text,
                    customUnlimDiscount: unlimDiscountController.text,
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
                    fClass = fClass.copyWith(campDays: classes);
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
                          child: const Text("CANCEL"),
                        ),
                        TextButton(
                          onPressed: () {
                            FirestoreService().setData(
                                path: FirestorePath.fClass(fClass.webAddressID),
                                data: fClass.toMap());
                            Navigator.pop(context);
                            Navigator.pop(context);
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
