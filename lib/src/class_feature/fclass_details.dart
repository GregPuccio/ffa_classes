import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/fencer_feature/fencer.dart';
import 'package:ffaclasses/src/fencer_feature/fencer_search.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:flutter/material.dart';

class FClassDetails extends StatefulWidget {
  const FClassDetails({Key? key}) : super(key: key);
  static const routeName = 'classDetails';

  @override
  State<FClassDetails> createState() => _FClassDetailsState();
}

class _FClassDetailsState extends State<FClassDetails> {
  bool edited = false;
  @override
  Widget build(BuildContext context) {
    ScreenArgs args = ModalRoute.of(context)!.settings.arguments! as ScreenArgs;
    FClass fClass = args.fClass!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${fClass.title} Class ${fClass.fencers.length}/${fClass.maxFencerNumber}"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  FencerSearch.routeName,
                  arguments: ScreenArgs(fClass: fClass),
                );
              },
              icon: const Icon(Icons.person_add)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                alignment: Alignment.topCenter,
                width:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? 600
                        : null,
                child: ListView.builder(
                  itemCount: fClass.fencers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${fClass.writtenDate}  ${fClass.startTime.format(context)}-${fClass.endTime.format(context)}",
                                  style: Theme.of(context).textTheme.subtitle1),
                              const Divider(),
                              Text(fClass.description,
                                  style: Theme.of(context).textTheme.subtitle2),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Card(
                        child: CheckboxListTile(
                          title: Text(fClass.fencers[index - 1].name),
                          value: fClass.fencers[index - 1].checkedIn,
                          onChanged: (val) {
                            setState(() {
                              if (edited == false) {
                                edited = true;
                              }
                              fClass.fencers[index - 1] =
                                  fClass.fencers[index - 1].copyWith(
                                      checkedIn:
                                          !fClass.fencers[index - 1].checkedIn);
                            });
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          InkButton(
            text: "Add fencer",
            onPressed: () {
              FirestoreService().addData(
                path: FirestorePath.users(),
                data: Fencer(
                  id: 'id',
                  firstName: 'John',
                  lastName: 'Test',
                  phoneNumber: '9083408640',
                  checkedIn: false,
                ).toMap(),
              );
              setState(() {
                edited = false;
              });
            },
          ),
          InkButton(
            active: edited,
            text: "Save",
            onPressed: () {
              FirestoreService().updateData(
                path: FirestorePath.fClass(fClass.id),
                data: fClass.toMap(),
              );
              setState(() {
                edited = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
