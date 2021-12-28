import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/class_feature/fclass_details.dart';
import 'package:ffaclasses/src/constants/links.dart';
import 'package:ffaclasses/src/constants/widgets/multi_select_chip.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
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
          List<List<FClass>> classesByDate = FClass.sortClassesByDate(classes);
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
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
                    child: CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              List<FClass> fClasses = classesByDate[index];
                              return StickyHeader(
                                header: Container(
                                  height: 50.0,
                                  color: Theme.of(context).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    fClasses.first.writtenDate,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                content: Column(
                                  children: fClasses.map((fClass) {
                                    return Column(
                                      children: [
                                        if (fClass != fClasses.first)
                                          const Divider(
                                            indent: 20,
                                            endIndent: 20,
                                            height: 1,
                                          ),
                                        ListTile(
                                          title: Text(fClass.title),
                                          subtitle: Text(
                                            "${fClass.fencers.length} fencers",
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(fClass.startTime
                                                  .format(context)),
                                              Text(fClass.endTime
                                                  .format(context)),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.restorablePushNamed(
                                              context,
                                              '${FClassDetails.routeName}/${fClass.id}',
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                            childCount: classesByDate.length,
                          ),
                        ),
                      ],
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
