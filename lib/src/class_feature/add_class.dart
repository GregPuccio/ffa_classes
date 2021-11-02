import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/enums.dart';
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
  @override
  void initState() {
    fClass = FClass(
      id: 'id',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      cost: 0,
      classType: widget.classType ?? ClassType.foundation,
      fencers: [],
    );
    super.initState();
  }

  void showDatePicker() async {
    await showDateRangePicker(
      context: context,
      firstDate: fClass.startTime,
      lastDate: fClass.endTime,
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
          MaterialButton(
            onPressed: showDatePicker,
            child: Text(fClass.dates),
          ),
        ],
      ),
    );
  }
}
