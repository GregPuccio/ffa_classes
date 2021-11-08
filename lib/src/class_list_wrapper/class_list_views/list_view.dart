import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/class_feature/fclass_details.dart';
import 'package:ffaclasses/src/constants/widgets/multi_select_chip.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:flutter/material.dart';

class ClassListView extends StatefulWidget {
  const ClassListView({Key? key}) : super(key: key);

  @override
  State<ClassListView> createState() => _ClassListViewState();
}

class _ClassListViewState extends State<ClassListView> {
  List<String> filters = ["All", "Foundation", "Youth", "Mixed", "Advanced"];

  int currentFilter = -1;

  void setFilter(String val) {
    setState(() {
      switch (val) {
        case "All":
          currentFilter = -1;
          break;
        case "Foundation":
          currentFilter = 0;
          break;
        case "Youth":
          currentFilter = 1;
          break;
        case "Mixed":
          currentFilter = 2;
          break;
        case "Advanced":
          currentFilter = 3;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FClass>>(
      stream: FirestoreService().collectionStream(
        path: FirestorePath.fClasses(),
        builder: (map, docID) => FClass.fromMap(map!).copyWith(id: docID),
        queryBuilder: (query) {
          if (currentFilter != -1) {
            return query
                .where('classType', isEqualTo: currentFilter)
                .orderBy('date');
          } else {
            return query.orderBy('date');
          }
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<FClass> classes = snapshot.data!;
          return Center(
            child: Container(
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).orientation == Orientation.landscape
                  ? 600
                  : null,
              child: Column(
                children: [
                  MultiSelectChip(
                    initialChoices: [filters.first],
                    itemList: filters,
                    onSelectionChanged: (val) => setFilter(val.first),
                    multi: false,
                    horizScroll: true,
                  ),
                  Flexible(
                    child: ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        FClass fClass = classes[index];
                        return Card(
                          child: ListTile(
                            title: Text("${fClass.writtenClassType} Class"),
                            subtitle: Text(
                              "${fClass.writtenDate} - ${fClass.startTime.format(context)}",
                            ),
                            trailing: Text("${fClass.fencers.length} fencers"),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                FClassDetails.routeName,
                                arguments: ScreenArgs(fClass: fClass),
                              );
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Class Deletion'),
                                  content: const Text(
                                      'Would you like to delete this class?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        FirestoreService().deleteData(
                                            path: FirestorePath.fClass(
                                                fClass.id));
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}