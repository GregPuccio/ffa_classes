import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:flutter/material.dart';

class EditStripCoaching extends StatefulWidget {
  final ScreenArgs args;
  const EditStripCoaching({required this.args, Key? key}) : super(key: key);
  static const routeName = "editStripCoaching";

  @override
  _EditStripCoachingState createState() => _EditStripCoachingState();
}

class _EditStripCoachingState extends State<EditStripCoaching> {
  late TextEditingController tournamentNameController;
  late TextEditingController tournamentDescriptionController;
  late TextEditingController regRateController;
  late TextEditingController regDiscountController;
  late TextEditingController notesController;
  late FClass fClass;

  @override
  void initState() {
    fClass = widget.args.fClass!;
    tournamentNameController =
        TextEditingController(text: fClass.customClassTitle);
    tournamentDescriptionController =
        TextEditingController(text: fClass.customClassDescription);
    regRateController = TextEditingController(text: fClass.customRegRate);
    regDiscountController =
        TextEditingController(text: fClass.customRegDiscount);
    notesController = TextEditingController(text: fClass.notes);
    super.initState();
  }

  @override
  void dispose() {
    tournamentNameController.dispose();
    tournamentDescriptionController.dispose();
    regRateController.dispose();
    regDiscountController.dispose();
    notesController.dispose();
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
        title: const Text("Edit Strip Coaching"),
        actions: [
          TextButton(
            onPressed: () {
              fClass = fClass.copyWith(
                customClassTitle: tournamentNameController.text,
                customClassDescription: tournamentDescriptionController.text,
                customRegRate: regRateController.text,
                customRegDiscount: regDiscountController.text,
                notes: notesController.text,
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
                      child: const Text("CANCEL"),
                    ),
                    TextButton(
                      onPressed: () {
                        FirestoreService().updateData(
                            path: FirestorePath.fClass(fClass.id),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: "Notes",
                    hintText:
                        "Add any notes for the tournament or anything else you need to remember, here",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
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
                              "Are you sure you would like to delete this tournament and all of its data? (Fencers registered/paid for, etc.)"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("CANCEL"),
                            ),
                            TextButton(
                              onPressed: () {
                                FirestoreService().deleteData(
                                  path: FirestorePath.fClass(fClass.id),
                                );
                                Navigator.popUntil(
                                    context, ModalRoute.withName('/'));
                              },
                              child: const Text("DELETE TOURNAMENT"),
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
