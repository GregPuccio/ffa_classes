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
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    controller.dispose();
    super.dispose();
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
      body: StreamBuilder<List<Fencer>>(
        stream: FirestoreService().userChildrentoFencerCollectionStream(
          path: FirestorePath.users(),
          builder: (map, docID) => Fencer.fromUserMap(map!),
          queryBuilder: (query) => query
              .orderBy('parentLastName')
              .where('searchTerms',
                  arrayContains: controller.text.toLowerCase())
              .where('admin', isEqualTo: false)
              .limit(20),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Fencer> fencers = snapshot.data!;
            return Column(
              children: [
                Flexible(
                  child: ListView.builder(
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
                  ),
                ),
                InkButton(
                  active: edited,
                  text: edited ? "Save changes" : "No changes made",
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
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
