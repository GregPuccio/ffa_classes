import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/constants/widgets/multi_select_chip.dart';
import 'package:ffaclasses/src/fencer_feature/fencer.dart';
import 'package:ffaclasses/src/fencer_feature/fencer_search.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:ffaclasses/src/strip_coaching_feature/edit_strip_coaching.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StripCoachingDetails extends StatefulWidget {
  final String id;
  const StripCoachingDetails({required this.id, Key? key}) : super(key: key);
  static const routeName = 'stripCoaching';

  @override
  State<StripCoachingDetails> createState() => _StripCoachingDetailsState();
}

class _StripCoachingDetailsState extends State<StripCoachingDetails> {
  List<String> dates = [];
  late FClass fClass;
  int dateIndex = -1;

  Future showCampRegistrationDialog(Fencer fencer, UserData userData) async {
    List<String> selectedDates = [];
    return showDialog(
      context: context,
      builder: (context) {
        selectedDates = fClass.findFencerCampDays(fencer);
        if (fClass.endDate != null) {
          dates = [];
          fClass.campDays?.removeWhere((day) =>
              day.fencers.length >=
              (int.tryParse(fClass.maxFencerNumber) ?? 100));
          dates.addAll(
            List.generate(fClass.campDays?.length ?? 0, (index) {
              return DateFormat('E M/d').format(fClass.campDays![index].date);
            }),
          );
        }
        bool fencerPaid = fencer.checkedIn;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Tournament Days"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Choose the tournament days you would like to sign${userData.admin ? " ${fencer.name}" : ""} up for strip coaching at."),
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
                      "Total Cost: \$${totalRegularCost(selectedDates, fClass)}"),
                  CheckboxListTile(
                    title: Text(
                        "Fencer ${fencerPaid ? "wants" : "does not want"} ${selectedDates.length > 1 ? "warmup lessons" : "a warmup lesson"}"),
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
                    Navigator.pop(context);
                  },
                  child: const Text("CANCEL"),
                ),
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

                    List<String> userIDs = [];

                    fClass.campDays?.forEach((day) {
                      for (var fencer in day.fencers) {
                        userIDs.add(fencer.id);
                      }
                    });

                    userIDs.removeWhere((id) => id == fencer.id);

                    fClass.campDays?.forEach((day) {
                      DateTime date = day.date;
                      String dateString = DateFormat('E M/d').format(date);
                      if (selectedDates.any((date) => date == dateString)) {
                        if (!day.fencers.contains(fencer)) {
                          day.fencers.add(fencer);
                        }
                        userIDs.add(fencer.id);
                      } else {
                        day.fencers.remove(fencer);
                      }
                    });

                    fClass = fClass.copyWith(userIDs: userIDs);

                    FirestoreService().updateData(
                      path: FirestorePath.fClass(fClass.id),
                      data: fClass.toMap(),
                    );

                    Navigator.pop(context, selectedDates.isNotEmpty);
                  },
                  child: const Text("CONFIRM"),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
              List<Fencer> fencersToShow = [];
              fencersToShow.addAll(fClass.fencersOnDay(dateIndex));
              return Scaffold(
                appBar: AppBar(
                  title: Text(fClass.title),
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
                                EditStripCoaching.routeName,
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
                                            Text("When:\n${fClass.dateRange}",
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
                                    if (fClass.campDays != null)
                                      MultiSelectChip(
                                        initialChoices: const ['All'],
                                        itemList: List.generate(
                                            fClass.campDays!.length + 1,
                                            (index) {
                                          if (index == 0) {
                                            return 'All';
                                          } else {
                                            return fClass.campDays![index - 1]
                                                .writtenDay;
                                          }
                                        }),
                                        onSelectionChanged: (val) {
                                          String date = val.first;
                                          int i = fClass.campDays!.indexWhere(
                                              (day) => day.writtenDay == date);
                                          setState(() {
                                            dateIndex = i;
                                          });
                                        },
                                        horizScroll: true,
                                        multi: false,
                                      ),
                                  ],
                                );
                              } else {
                                Fencer fencer = fencersToShow[index - 1];
                                Widget? subtitle;
                                String text = "";
                                if (fClass.campDays != null &&
                                    fClass.campDays!.isNotEmpty) {
                                  bool first = true;
                                  for (var day in fClass.campDays!) {
                                    if (day.fencers.contains(fencer)) {
                                      if (!first) {
                                        text = text + " | ";
                                      }
                                      text = text +
                                          DateFormat("E M/d").format(day.date);
                                      first = false;
                                    }
                                  }
                                  subtitle = Text(text);
                                  return Card(
                                    child: ListTile(
                                      title: Text(fencer.name +
                                          (fencer.checkedIn && userData.admin
                                              ? " (wants lessons)"
                                              : "")),
                                      subtitle: subtitle,
                                      trailing: userData.admin
                                          ? const Icon(Icons.edit)
                                          : null,
                                      onTap: userData.admin
                                          ? () {
                                              showCampRegistrationDialog(
                                                fencer,
                                                userData,
                                              );
                                            }
                                          : null,
                                    ),
                                  );
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
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
                            : 'Sign up for camp',
                        onPressed: () async {
                          Fencer fencer;
                          if (userData.children.length == 1) {
                            fencer = userData.toFencer(0);
                          } else {
                            fencer = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Select Fencer"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                            "Please select which fencer you are registering for the camp. Registration is done one fencer at a time."),
                                        MultiSelectChip(
                                          itemList: userData.children
                                              .map((child) => child.firstName)
                                              .toList(),
                                          onSelectionChanged: (val) {
                                            Navigator.pop(
                                                context,
                                                userData
                                                    .fencersFromFirstName(val)
                                                    .first);
                                          },
                                          multi: false,
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          }
                          dynamic result = await showCampRegistrationDialog(
                            fencer,
                            userData,
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
                                          child: const Text("OK"))
                                    ],
                                  );
                                });
                          }
                        },
                      ),
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

int totalRegularCost(List<String> selectedDates, FClass fClass) {
  int firstEvent = int.tryParse(fClass.customRegRate ?? "0") ?? 0;
  int addEvent = int.tryParse(fClass.customRegDiscount ?? "0") ?? 0;
  int numAdd = selectedDates.length - 1;
  int price = selectedDates.isNotEmpty ? (firstEvent + numAdd * addEvent) : 0;
  return price;
}
