import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:flutter/material.dart';

class FClassDetails extends StatelessWidget {
  const FClassDetails({Key? key}) : super(key: key);
  static const routeName = 'classDetails';

  @override
  Widget build(BuildContext context) {
    ScreenArgs args = ModalRoute.of(context)!.settings.arguments! as ScreenArgs;
    FClass fClass = args.fClass!;
    return Scaffold(
      appBar: AppBar(
        title: Text(fClass.writtenClassType),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).orientation == Orientation.landscape
              ? 600
              : null,
          child: ListView(
            children: [
              Text(fClass.writtenDate),
            ],
          ),
        ),
      ),
    );
  }
}
