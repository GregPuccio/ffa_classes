import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/constants/widgets/multi_select_chip.dart';
import 'package:flutter/material.dart';

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
  @override
  void initState() {
    fClass = FClass(
      id: 'id',
      date: DateTime.now(),
      startTime: TimeOfDay.now(),
      endTime: TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1),
      cost: 0,
      classType: widget.classType ?? ClassType.foundation,
      fencers: [],
    );
    repeat = false;
    super.initState();
  }

  void showTimeSelector() async {
    await showTimePicker(context: context, initialTime: fClass.startTime);
  }

  void showDateChooser() async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 31)),
      lastDate: DateTime.now().add(const Duration(days: 100)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Class'),
      ),
      body: ListView(
        children: [
          MultiSelectChip(
            itemList: const ['Foundation', 'Youth', 'Mixed', 'Advanced'],
            onSelectionChanged: (val) => setState(() {}),
            multi: false,
          ),
          SecondaryButton(
            active: true,
            onPressed: showDateChooser,
            text: fClass.date.toString(),
          ),
          SecondaryButton(
            active: true,
            onPressed: showTimeSelector,
            text: fClass.times,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Class cost',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: CheckboxListTile(
                title: const Text('Repeat for the full month?'),
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
            text: 'Save',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
