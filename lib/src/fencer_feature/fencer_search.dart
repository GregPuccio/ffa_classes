import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/constants/widgets/search_bar.dart';
import 'package:ffaclasses/src/fencer_feature/fencer.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:flutter/material.dart';

class FencerSearch extends StatefulWidget {
  const FencerSearch({Key? key}) : super(key: key);
  static const routeName = 'fencerSearch';

  @override
  _FencerSearchState createState() => _FencerSearchState();
}

class _FencerSearchState extends State<FencerSearch> {
  late TextEditingController controller;
  bool edited = false;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenArgs args = ModalRoute.of(context)!.settings.arguments! as ScreenArgs;
    FClass fClass = args.fClass!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fencer Search"),
        bottom: searchBar(controller, Theme.of(context).cardColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Fencer>>(
              stream: FirestoreService().collectionStream(
                path: FirestorePath.users(),
                builder: (map, docID) =>
                    Fencer.fromMap(map!).copyWith(id: docID),
                queryBuilder: (query) => query
                    .orderBy('searchName')
                    .where('searchName',
                        isGreaterThanOrEqualTo: controller.text)
                    .where('admin', isEqualTo: false)
                    .limit(20),
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Fencer> fencers = snapshot.data!;
                  return ListView.builder(
                    itemCount: fencers.length,
                    itemBuilder: (context, index) {
                      Fencer fencer = fencers[index];
                      return Card(
                        child: CheckboxListTile(
                          title: Text(fencer.name),
                          value: fClass.fencers.contains(fencer),
                          onChanged: (val) {
                            if (edited == false) {
                              edited = true;
                            }
                            setState(() {
                              if (val == true) {
                                fClass.fencers.add(fencer);
                              } else {
                                fClass.fencers.remove(fencer);
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          InkButton(
            active: edited,
            text: "Save changes",
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
