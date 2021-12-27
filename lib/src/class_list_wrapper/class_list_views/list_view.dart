import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/class_feature/fclass_details.dart';
import 'package:ffaclasses/src/constants/links.dart';
import 'package:ffaclasses/src/constants/widgets/multi_select_chip.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassListView extends StatefulWidget {
  const ClassListView({Key? key}) : super(key: key);

  @override
  State<ClassListView> createState() => _ClassListViewState();
}

class _ClassListViewState extends State<ClassListView> {
  List<String> filters = [
    "All",
    "Foundation",
    "Youth",
    "Mixed",
    "Advanced",
    "Camps"
  ];

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
        case "Camps":
          currentFilter = 4;
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
          DateTime now = DateTime.now();
          DateTime thisMonth = DateTime.utc(now.year, now.month);
          if (currentFilter != -1) {
            return query
                .where('classType', isEqualTo: currentFilter)
                .orderBy('date')
                .where('date',
                    isGreaterThanOrEqualTo: thisMonth.millisecondsSinceEpoch);
          } else {
            return query.orderBy('date').where('date',
                isGreaterThanOrEqualTo: thisMonth.millisecondsSinceEpoch);
          }
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<FClass> classes = snapshot.data!;
          classes.sort();
          return Center(
            child: Container(
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).orientation == Orientation.landscape
                  ? 600
                  : null,
              child: Column(
                children: [
                  ListTile(
                      title: const Text(
                        "Book Private Lessons (on Square)",
                        textAlign: TextAlign.center,
                      ),
                      trailing: const Icon(Icons.launch),
                      onTap: () {
                        launch(squareLessonsLink);
                      }),
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
                            title: Text(fClass.title),
                            subtitle: Text(
                              "${fClass.dateRange} | ${fClass.startTime.format(context)}",
                            ),
                            trailing: Text("${fClass.fencers.length} fencers"),
                            onTap: () {
                              Navigator.restorablePushNamed(
                                context,
                                '${FClassDetails.routeName}/${fClass.id}',
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
