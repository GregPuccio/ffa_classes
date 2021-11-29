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
  const FClassDetails({Key? key}) : super(key: key);
  static const routeName = 'classDetails';

  @override
  State<FClassDetails> createState() => _FClassDetailsState();
}

class _FClassDetailsState extends State<FClassDetails> {
  bool edited = false;
  List<String> dates = [];
  List<String> selectedDates = [];
  @override
  Widget build(BuildContext context) {
    ScreenArgs args = ModalRoute.of(context)!.settings.arguments! as ScreenArgs;
    FClass fClass = args.fClass!;
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return StreamBuilder<FClass>(
          stream: FirestoreService().documentStream(
              path: FirestorePath.fClass(fClass.id),
              builder: (map, docID) =>
                  FClass.fromMap(map!).copyWith(id: docID)),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              fClass = snapshot.data!;
            }
            selectedDates = fClass.findFencerCampDays(userData.toFencer());
            return Scaffold(
              appBar: AppBar(
                title: Text(
                    "${fClass.title} ${fClass.fencers.length}/${fClass.maxFencerNumber == "0" ? "\u221E" : fClass.maxFencerNumber}"),
                actions: [
                  if (userData.admin)
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
                ],
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
                                            "Cost: ${fClass.classCost}",
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
                                  ),
                                );
                              } else {
                                return Card(
                                  child: CheckboxListTile(
                                    title: Text(fencer.name),
                                    subtitle: subtitle,
                                    value: fencer.checkedIn,
                                    onChanged: userData.admin
                                        ? (val) {
                                            setState(() {
                                              if (edited == false) {
                                                edited = true;
                                              }
                                              fClass.fencers[index - 1] = fClass
                                                  .fencers[index - 1]
                                                  .copyWith(
                                                      checkedIn: !fClass
                                                          .fencers[index - 1]
                                                          .checkedIn);
                                            });
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
                  if (userData.admin)
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
                  if (!userData.admin)
                    InkButton(
                      active: fClass.date.isAfter(DateTime.now()),
                      text: fClass.fencers.contains(userData.toFencer())
                          ? (fClass.classType == ClassType.camp
                                  ? "Edit"
                                  : "Remove") +
                              " registration"
                          : 'Sign up for ${fClass.classType == ClassType.camp ? "camp" : "class"}',
                      onPressed: () async {
                        if (fClass.classType == ClassType.camp) {
                          dynamic result = await showDialog(
                            context: context,
                            builder: (context) {
                              if (fClass.endDate != null) {
                                dates = [];
                                dates.addAll(
                                  List.generate(fClass.campDays?.length ?? 0,
                                      (index) {
                                    DateTime date =
                                        fClass.date.add(Duration(days: index));
                                    return DateFormat('E M/d').format(date);
                                  }),
                                );
                              }
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title: const Text("Camp Days"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                            "Choose the camp days you would like to sign up for."),
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
                                            "Total Cost: \$${totalCost(dates, selectedDates)}")
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          if (selectedDates.isNotEmpty) {
                                            if (!fClass.fencers.contains(
                                                userData.toFencer())) {
                                              fClass.fencers
                                                  .add(userData.toFencer());
                                            }
                                          } else {
                                            fClass.fencers
                                                .remove(userData.toFencer());
                                          }
                                          fClass.campDays?.forEach((day) {
                                            DateTime date = day.date;
                                            String dateString =
                                                DateFormat('E M/d')
                                                    .format(date);
                                            if (selectedDates.any(
                                                (date) => date == dateString)) {
                                              if (!day.fencers.contains(
                                                  userData.toFencer())) {
                                                day.fencers
                                                    .add(userData.toFencer());
                                              }
                                            } else {
                                              day.fencers
                                                  .remove(userData.toFencer());
                                            }
                                          });
                                          FirestoreService().updateData(
                                            path:
                                                FirestorePath.fClass(fClass.id),
                                            data: fClass.toMap(),
                                          );

                                          Navigator.pop(context, true);
                                        },
                                        child: const Text("Confirm"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
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
                            if (fClass.fencers.contains(userData.toFencer())) {
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

int totalCost(List<String> dates, List<String> selectedDates) {
  int totalLength = dates.length;
  int numTrue = selectedDates.length;
  bool discountPrice = totalLength == numTrue;
  return discountPrice ? 500 : 110 * numTrue;
}
