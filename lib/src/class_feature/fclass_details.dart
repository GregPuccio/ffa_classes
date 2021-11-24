import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
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
  List<Widget> dates = [];
  List<bool> isSelected = [];
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
            return Scaffold(
              appBar: AppBar(
                title: Text(
                    "${fClass.title} ${fClass.fencers.length}/${fClass.maxFencerNumber == "0" ? "\u221E" : fClass.maxFencerNumber}"),
                actions: [
                  if (userData.admin)
                    IconButton(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          FencerSearch.routeName,
                          arguments: ScreenArgs(fClass: fClass),
                        );
                        setState(() {
                          fClass = result as FClass;
                        });
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
                                              "${fClass.writtenDate}  ${fClass.startTime.format(context)}-${fClass.endTime.format(context)}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1),
                                          const Divider(),
                                          Text(fClass.description,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: ListTile(
                                      title: Text(
                                        "Cost: ${fClass.classCost}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Card(
                                child: CheckboxListTile(
                                  title: Text(fClass.fencers[index - 1].name),
                                  value: fClass.fencers[index - 1].checkedIn,
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
                          ? 'Remove registration'
                          : 'Sign up for ${fClass.classType == ClassType.camp ? "camp" : "class"}',
                      onPressed: () {
                        if (fClass.classType == ClassType.camp) {
                          if (fClass.fencers.contains(userData.toFencer())) {
                            fClass.fencers.remove(userData.toFencer());
                            for (var day in fClass.campDays!) {
                              day.fencers.remove(userData.toFencer());
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                if (fClass.endDate != null) {
                                  dates.addAll(
                                    List.generate(
                                        daysBetween(
                                            fClass.date, fClass.endDate!),
                                        (index) {
                                      DateTime date = fClass.date
                                          .add(Duration(days: index));
                                      return Text(
                                          "${DateFormat('E').format(date)} ${date.month}/${date.day}");
                                    }),
                                  );
                                  isSelected.addAll(List.generate(
                                      daysBetween(fClass.date, fClass.endDate!),
                                      (index) => false));
                                }
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: const Text("Camp Days"),
                                      content: Column(
                                        children: [
                                          const Text(
                                              "Choose the camp days you would like to sign up for."),
                                          ToggleButtons(
                                            children: dates,
                                            isSelected: isSelected,
                                            onPressed: (val) {
                                              setState(() {
                                                isSelected[val] =
                                                    !isSelected[val];
                                              });
                                            },
                                          ),
                                          Text(
                                              "Total Cost: ${totalCost(isSelected)}")
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              fClass.fencers
                                                  .add(userData.toFencer());
                                              fClass.campDays?.forEach((day) {
                                                if (isSelected[fClass.campDays!
                                                    .indexOf(day)]) {
                                                  day.fencers
                                                      .add(userData.toFencer());
                                                }
                                              });
                                            });
                                            Navigator.pop(context);
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
                        } else {
                          setState(() {
                            if (fClass.fencers.contains(userData.toFencer())) {
                              fClass.fencers.remove(userData.toFencer());
                            } else {
                              fClass.fencers.add(userData.toFencer());
                            }
                          });
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

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

int totalCost(List<bool> isSelected) {
  int totalLength = isSelected.length;
  int numTrue = isSelected.where((val) => val == true).length;
  bool discountPrice = totalLength == numTrue;
  return discountPrice ? 500 : 110 * numTrue;
}
