import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/class_feature/edit_class.dart';
import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/constants/widgets/multi_select_chip.dart';
import 'package:ffaclasses/src/fencer_feature/fencer.dart';
import 'package:ffaclasses/src/fencer_feature/fencer_search.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FClassDetails extends StatefulWidget {
  final String id;
  const FClassDetails({required this.id, Key? key}) : super(key: key);
  static const routeName = 'classes';

  @override
  State<FClassDetails> createState() => _FClassDetailsState();
}

class _FClassDetailsState extends State<FClassDetails> {
  List<String> dates = [];
  late FClass fClass;

  Future showChangeCoachStatus(UserData userData, {bool add = true}) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${add ? "Add" : "Remove"} myself"),
          content: Text(
              "Are you sure you want to ${add ? "add" : "remove"} yourself ${add ? "to" : "from"} this camp/class as a coach?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  if (add) {
                    fClass.coaches.add(userData.toCoach());
                  } else {
                    fClass.coaches.remove(userData.toCoach());
                  }
                  FirestoreService()
                      .updateData(path: FirestorePath.fClass(fClass.id), data: {
                    'coaches': fClass.coaches.map((x) => x.toMap()).toList(),
                  });
                  Navigator.pop(context);
                },
                child: Text("${add ? "Add" : "Remove"} me")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return StreamBuilder<FClass>(
          stream: FirestoreService().documentStream(
              path: FirestorePath.fClass(widget.id),
              builder: (map, docID) =>
                  FClass.fromMap(map!).copyWith(id: docID)),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              fClass = snapshot.data!;
              List<Fencer> fencersToShow = fClass.fencers;
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      "${fClass.title} | ${fClass.fencers.length}/${fClass.maxFencerNumber} Registered"),
                  actions: userData.admin
                      ? [
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                FencerSearch.routeName,
                                arguments: ScreenArgs(fClass: fClass),
                              );
                            },
                            icon: const Icon(Icons.person_add),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                EditClass.routeName,
                                arguments: ScreenArgs(fClass: fClass),
                              );
                            },
                            icon: const Icon(Icons.settings),
                          ),
                        ]
                      : null,
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          alignment: Alignment.topCenter,
                          width: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 600
                              : null,
                          child: ListView.builder(
                            itemCount: fencersToShow.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Column(
                                  children: [
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (fClass.coachNames.isNotEmpty ||
                                                userData.admin) ...[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      "Coaches:\n${fClass.coachNames}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1),
                                                  if (userData.admin &&
                                                      fClass.coaches.contains(
                                                          userData.toCoach()))
                                                    TextButton(
                                                      onPressed: () {
                                                        showChangeCoachStatus(
                                                          userData,
                                                          add: false,
                                                        );
                                                      },
                                                      child: const Text(
                                                          "Remove myself"),
                                                    )
                                                  else if (userData.admin)
                                                    TextButton(
                                                      onPressed: () {
                                                        showChangeCoachStatus(
                                                          userData,
                                                        );
                                                      },
                                                      child: const Text(
                                                          "Add myself"),
                                                    ),
                                                ],
                                              ),
                                              const Divider(),
                                            ],
                                            Text(
                                                "When:\n${fClass.dateRange} | ${fClass.startTime.format(context)}-${fClass.endTime.format(context)}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1),
                                            const Divider(),
                                            Text(
                                              "Cost:\n${fClass.classCost}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1,
                                            ),
                                            const Divider(),
                                            Text(fClass.description,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                Fencer fencer = fencersToShow[index - 1];
                                return Card(
                                  child: ListTile(
                                    title: Text(fencer.name),
                                    subtitle: Text(
                                      fencer.checkedIn ? "Present" : "Absent",
                                    ),
                                    trailing: userData.admin
                                        ? const Icon(Icons.edit)
                                        : null,
                                    onTap: userData.admin
                                        ? () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Change Status"),
                                                  content: Text(
                                                      "${fencer.name} is currently ${fencer.checkedIn ? "" : "not "}checked in, if you would like to change that please use the button below."),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        fClass.fencers[
                                                                index - 1] =
                                                            fencer.copyWith(
                                                                checkedIn: !fencer
                                                                    .checkedIn);
                                                        FirestoreService()
                                                            .updateData(
                                                          path: FirestorePath
                                                              .fClass(
                                                                  fClass.id),
                                                          data: fClass.toMap(),
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                          "MARK FENCER ${fencer.checkedIn ? 'ABSENT' : 'PRESENT'}"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        : null,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    if (!userData.admin)
                      InkButton(
                        // active: fClass.date.isAfter(
                        //   DateTime.utc(
                        //     DateTime.now().year,
                        //     DateTime.now().month,
                        //     DateTime.now().day - 1,
                        //   ),
                        // ),
                        text: userData.isFencerInList(fClass.fencers)
                            ? "Edit registration"
                            : 'Sign up for class',
                        onPressed: () async {
                          if (userData.children.length == 1) {
                            /// if the user only has one child
                            if (userData.isFencerInList(fClass.fencers)) {
                              /// if the child is in the list
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete Registration'),
                                      content: Text(
                                          "Would you like to delete ${userData.toFencer(0).firstName}'s registration for this class?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("CANCEL"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            fClass.userIDs.remove(
                                                userData.fencers()[0].id);
                                            fClass.fencers
                                                .remove(userData.toFencer(0));
                                            FirestoreService().updateData(
                                              path: FirestorePath.fClass(
                                                  fClass.id),
                                              data: fClass.toMap(),
                                            );
                                            Navigator.pop(context);
                                          },
                                          child:
                                              const Text("DELETE REGISTRATION"),
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              /// if the child is not in the list
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Register'),
                                      content: Text(
                                          "Would you like to register ${userData.toFencer(0).firstName} for this class?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("CANCEL"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            fClass.userIDs
                                                .add(userData.fencers()[0].id);
                                            fClass.fencers
                                                .add(userData.toFencer(0));
                                            FirestoreService().updateData(
                                              path: FirestorePath.fClass(
                                                  fClass.id),
                                              data: fClass.toMap(),
                                            );
                                            Navigator.pop(context);
                                          },
                                          child: const Text("REGISTER"),
                                        ),
                                      ],
                                    );
                                  });
                            }
                          } else {
                            /// if the user has multiple children
                            showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                    builder: (context, setState) {
                                  List<Fencer> fencers =
                                      userData.fencersInList(fClass.fencers);
                                  List<String> userIDs = [];
                                  return AlertDialog(
                                    title: const Text('Edit Registration'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                            "Select the child(ren) you would like to sign up for this class:"),
                                        MultiSelectChip(
                                          initialChoices: fencers
                                              .map((child) => child.firstName)
                                              .toList(),
                                          itemList: userData.children
                                              .map((child) => child.firstName)
                                              .toList(),
                                          onSelectionChanged: (val) {
                                            fencers = [];
                                            fencers.addAll(fClass.fencers);
                                            userIDs.addAll(fClass.userIDs);
                                            for (var fencer in userData
                                                .fencersInList(fencers)) {
                                              fencers.remove(fencer);
                                              userIDs.remove(fencer.id);
                                            }
                                            fencers.addAll(userData
                                                .fencersFromFirstName(val));
                                            userIDs.addAll(userData
                                                .fencersFromFirstName(val)
                                                .map((e) => e.id));
                                            fencers = fencers.toSet().toList();
                                            userIDs = userIDs.toSet().toList();
                                          },
                                        ),
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
                                          fClass = fClass.copyWith(
                                              fencers: fencers,
                                              userIDs: userIDs);
                                          FirestoreService().updateData(
                                            path:
                                                FirestorePath.fClass(fClass.id),
                                            data: fClass.toMap(),
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: const Text("CONFIRM CHANGES"),
                                      ),
                                    ],
                                  );
                                });
                              },
                            );
                          }
                          FirestoreService().updateData(
                            path: FirestorePath.fClass(fClass.id),
                            data: fClass.toMap(),
                          );
                        },
                      )
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    }

    return Consumer(
      builder: (context, watch, child) {
        return watch.watch(userDataProvider).when(
              data: whenData,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (object, stackTrace) => const AuthWrapper(),
            );
      },
    );
  }
}
