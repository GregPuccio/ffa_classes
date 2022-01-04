import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:flutter/material.dart';

class AddStripCoaching extends StatefulWidget {
  const AddStripCoaching({Key? key}) : super(key: key);
  static const routeName = 'addStripCoaching';

  @override
  _AddStripCoachingState createState() => _AddStripCoachingState();
}

class _AddStripCoachingState extends State<AddStripCoaching> {
  late FClass fClass;
  late TextEditingController tournamentNameController;
  late TextEditingController tournamentDescriptionController;
  late TextEditingController regRateController;
  late TextEditingController regDiscountController;

  @override
  void initState() {
    fClass = FClass.create(classType: ClassType.stripCoaching);
    tournamentNameController = TextEditingController();
    tournamentDescriptionController = TextEditingController();
    regRateController = TextEditingController();
    regDiscountController = TextEditingController();
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
    tournamentNameController.dispose();
    tournamentDescriptionController.dispose();
    regRateController.dispose();
    regDiscountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Tournament'),
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
                  controller: tournamentNameController,
                  decoration: const InputDecoration(
                    labelText: "Tournament Name",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: tournamentDescriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description/Location",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ),
              SecondaryButton(
                active: true,
                onPressed: showDateChooser,
                text: fClass.dateRange,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: regRateController,
                        decoration: const InputDecoration(
                          labelText: "First Event",
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
                          labelText: "Add'l Event",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkButton(
                text: 'Create tournament',
                onPressed: () {
                  fClass = fClass.copyWith(
                    customClassTitle: tournamentNameController.text,
                    customClassDescription:
                        tournamentDescriptionController.text,
                    customRegRate: regRateController.text,
                    customRegDiscount: regDiscountController.text,
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
