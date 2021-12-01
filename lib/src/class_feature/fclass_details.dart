import 'package:ffaclasses/src/camp_feature/edit_camp.dart';
import 'package:ffaclasses/src/class_feature/edit_class.dart';
import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/enums.dart';
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
import 'package:intl/intl.dart';
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
  List<String> selectedDates = [];
  late FClass fClass;
  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        Future showCampRegistrationDialog(Fencer fencer) {
          return showDialog(
            context: context,
            builder: (context) {
              selectedDates = fClass.findFencerCampDays(fencer);
              if (fClass.endDate != null) {
                dates = [];
                fClass.campDays?.removeWhere((day) =>
                    day.fencers.length >=
                    (int.tryParse(fClass.maxFencerNumber) ?? 0));
                dates.addAll(
                  List.generate(fClass.campDays?.length ?? 0, (index) {
                    return DateFormat('E M/d')
                        .format(fClass.campDays![index].date);
                  }),
                );
              }
              bool fencerPaid = fencer.checkedIn;
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Camp Days"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            "Choose the camp days you would like to sign${userData.admin ? " ${fencer.name}" : ""} up for."),
                        MultiSelectChip(
                          itemList: dates,
                          initialChoices: selectedDates,
                          onSelectionChanged: (val) {
                            setState(() {
                              selectedDates = val;
                            });
                          },
                        ),
                        Text(
                            "Regular Membership Cost: \$${totalRegularCost(dates, selectedDates)}"),
                        Text(
                            "Unlimited Membership Cost: \$${totalUnlimitedCost(dates, selectedDates)}"),
                        if (userData.admin)
                          CheckboxListTile(
                            title: Text(
                                "Fencer has ${fencerPaid ? "" : "not "}paid"),
                            value: fencerPaid,
                            onChanged: (val) {
                              setState(() {
                                fencerPaid = !fencerPaid;
                              });
                            },
                          )
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (selectedDates.isNotEmpty) {
                            fencer = fencer.copyWith(checkedIn: fencerPaid);

                            if (!fClass.fencers.contains(fencer)) {
                              fClass.fencers.add(fencer);
                            } else {
                              fClass.fencers.remove(fencer);
                              fClass.fencers.add(fencer);
                            }
                          } else {
                            fClass.fencers.remove(fencer);
                          }

                          fClass.campDays?.forEach((day) {
                            DateTime date = day.date;
                            String dateString =
                                DateFormat('E M/d').format(date);
                            if (selectedDates
                                .any((date) => date == dateString)) {
                              if (!day.fencers.contains(fencer)) {
                                day.fencers.add(fencer);
                              }
                            } else {
                              day.fencers.remove(fencer);
                            }
                          });
                          FirestoreService().updateData(
                            path: FirestorePath.fClass(fClass.id),
                            data: fClass.toMap(),
                          );

                          Navigator.pop(context, selectedDates.isNotEmpty);
                        },
                        child: const Text("Confirm"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        }

        return StreamBuilder<FClass>(
          stream: FirestoreService().documentStream(
              path: FirestorePath.fClass(widget.id),
              builder: (map, docID) =>
                  FClass.fromMap(map!).copyWith(id: docID)),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              fClass = snapshot.data!;
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      "${fClass.title} | ${fClass.fencers.length}/${fClass.maxFencerNumber == "0" ? "\u221E" : fClass.maxFencerNumber} Registered"),
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
                                fClass.classType == ClassType.camp
                                    ? EditCamp.routeName
                                    : EditClass.routeName,
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
                            itemCount: fClass.fencers.length + 1,
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
                                            Text(
                                                "When: ${fClass.dateRange} | ${fClass.startTime.format(context)}-${fClass.endTime.format(context)}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1),
                                            const Divider(),
                                            Text(
                                              "Cost:${fClass.classCost}",
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
                                Fencer fencer = fClass.fencers[index - 1];
                                Widget? subtitle;
                                String text = "";
                                if (fClass.classType == ClassType.camp &&
                                    fClass.campDays != null) {
                                  for (var day in fClass.campDays!) {
                                    if (day.fencers.contains(fencer)) {
                                      text = text +
                                          "${DateFormat("E M/d").format(day.date)} | ";
                                    }
                                  }
                                  subtitle = Text(text);
                                  return Card(
                                    child: ListTile(
                                      title: Text(fencer.name),
                                      subtitle: subtitle,
                                      trailing: userData.admin
                                          ? const Icon(Icons.edit)
                                          : null,
                                      onTap: userData.admin
                                          ? () {
                                              showCampRegistrationDialog(
                                                  fencer);
                                            }
                                          : null,
                                    ),
                                  );
                                } else {
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
                                                            data:
                                                                fClass.toMap(),
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                            "Mark as ${fencer.checkedIn ? 'absent' : 'present'}"),
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
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    if (!userData.admin)
                      InkButton(
                        active: fClass.date.isAfter(
                          DateTime.utc(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day - 1,
                          ),
                        ),
                        text: fClass.fencers.contains(userData.toFencer())
                            ? (fClass.classType == ClassType.camp
                                    ? "Edit"
                                    : "Remove") +
                                " registration"
                            : 'Sign up for ${fClass.classType == ClassType.camp ? "camp" : "class"}',
                        onPressed: () async {
                          if (fClass.classType == ClassType.camp) {
                            dynamic result = await showCampRegistrationDialog(
                                userData.toFencer());
                            if (result != null && result == true) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("All set!"),
                                      content: Text(
                                          "You are now registered for ${fClass.title}, payments can be given to any coach directly and then your status will be updated to paid. Thank you!"),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Ok"))
                                      ],
                                    );
                                  });
                            }
                          } else {
                            setState(() {
                              if (fClass.fencers
                                  .contains(userData.toFencer())) {
                                fClass.fencers.remove(userData.toFencer());
                              } else {
                                fClass.fencers.add(userData.toFencer());
                              }
                            });
                            FirestoreService().updateData(
                              path: FirestorePath.fClass(fClass.id),
                              data: fClass.toMap(),
                            );
                          }
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
        return Center(
          child: Text(
            "Error",
            style: Theme.of(context).textTheme.headline6,
          ),
        );
      }
    }

    return Consumer(
      builder: (context, watch, child) {
        return watch.watch(userDataProvider).when(
              data: whenData,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (object, stackTrace) => Center(
                child: Text(
                  "Error",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            );
      },
    );
  }
}

int totalRegularCost(List<String> dates, List<String> selectedDates) {
  int totalLength = dates.length;
  int numTrue = selectedDates.length;
  bool discountPrice = totalLength == numTrue;
  return discountPrice ? 550 : 110 * numTrue;
}

int totalUnlimitedCost(List<String> dates, List<String> selectedDates) {
  int totalLength = dates.length;
  int numTrue = selectedDates.length;
  bool discountPrice = totalLength == numTrue;
  return discountPrice ? 500 : 100 * numTrue;
}
