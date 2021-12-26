import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/user_feature/child.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditAccount extends StatefulWidget {
  final UserData userData;
  const EditAccount({Key? key, required this.userData}) : super(key: key);
  static const routeName = 'editAccount';

  @override
  _EditAccountState createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  late TextEditingController parentFirstName;
  late TextEditingController parentLastName;
  late List<TextEditingController> childrenFirstNames;
  late List<TextEditingController> childrenLastNames;
  late bool member;
  late bool unlimitedMember;
  bool edited = false;
  @override
  void initState() {
    childrenFirstNames = List.generate(
        widget.userData.children.length,
        (index) => TextEditingController(
            text: widget.userData.children[index].firstName));
    childrenLastNames = List.generate(
        widget.userData.children.length,
        (index) => TextEditingController(
            text: widget.userData.children[index].lastName));

    parentFirstName =
        TextEditingController(text: widget.userData.parentFirstName);
    parentLastName =
        TextEditingController(text: widget.userData.parentLastName);

    member = widget.userData.member;
    unlimitedMember = widget.userData.unlimitedMember;
    super.initState();
  }

  @override
  void dispose() {
    for (var element in childrenFirstNames) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Account"),
          actions: [
            if (userData != null &&
                widget.userData.id != userData.id &&
                userData.admin)
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (context, setState2) {
                          return AlertDialog(
                            title: const Text("Membership Information"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CheckboxListTile(
                                  title: const Text("Club Member"),
                                  value: member,
                                  onChanged: (val) {
                                    setState2(() {
                                      member = val!;
                                      if (val == false) {
                                        unlimitedMember = false;
                                      }
                                    });
                                  },
                                ),
                                CheckboxListTile(
                                  title: const Text("Unlimited Member"),
                                  value: unlimitedMember,
                                  onChanged: member
                                      ? (val) {
                                          setState2(() {
                                            unlimitedMember = val!;
                                          });
                                        }
                                      : null,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                child: const Text("Save Changes"),
                                onPressed: () {
                                  UserData user = widget.userData.copyWith(
                                    member: member,
                                    unlimitedMember: unlimitedMember,
                                  );

                                  FirestoreService().setData(
                                    path:
                                        FirestorePath.user(widget.userData.id),
                                    data: user.toMap(),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Membership info has been successfully updated!"),
                                    ),
                                  );
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                      });
                },
                icon: const Icon(Icons.verified_user),
              ),
          ],
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Flexible(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Membership Type:",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.userData.admin
                            ? "Coach/Administrator"
                            : "${unlimitedMember ? "Unlimited " : ""}${member ? "Club Member" : "Non-Member"}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Parent:",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                textCapitalization: TextCapitalization.words,
                                controller: parentFirstName,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "First Name",
                                ),
                                onChanged: (val) {
                                  if (!edited) {
                                    setState(() {
                                      edited = true;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                textCapitalization: TextCapitalization.words,
                                controller: parentLastName,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Last Name",
                                ),
                                onChanged: (val) {
                                  if (!edited) {
                                    setState(() {
                                      edited = true;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Children:",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      Column(
                        children: List.generate(
                          childrenFirstNames.length,
                          (index) {
                            return Row(
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: childrenFirstNames[index],
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "First Name",
                                      ),
                                      onChanged: (val) {
                                        if (!edited) {
                                          setState(() {
                                            edited = true;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      controller: childrenLastNames[index],
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Last Name",
                                      ),
                                      onChanged: (val) {
                                        if (!edited) {
                                          setState(() {
                                            edited = true;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                      Row(
                        children: [
                          if (childrenFirstNames.length > 1)
                            Flexible(
                              child: SecondaryButton(
                                onPressed: () {
                                  setState(() {
                                    // if (childrenFirstNames.length > 1) {
                                    childrenFirstNames.removeLast();
                                    childrenLastNames.removeLast();
                                    // }
                                    if (!edited) {
                                      edited = true;
                                    }
                                  });
                                },
                                text: "- Remove child",
                                activeColor: Colors.red,
                              ),
                            ),
                          Flexible(
                            child: SecondaryButton(
                              text: "+ Add child",
                              active: true,
                              onPressed: () {
                                setState(() {
                                  childrenFirstNames
                                      .add(TextEditingController());
                                  childrenLastNames.add(TextEditingController(
                                    text: parentLastName.text,
                                  ));
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                InkButton(
                  text: "Save changes",
                  active: edited,
                  onPressed: () {
                    if (parentFirstName.text.isEmpty ||
                        parentLastName.text.isEmpty ||
                        childrenFirstNames.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please make sure all fields are filled in and you have added your child/children!"),
                        ),
                      );
                    } else {
                      List<Child> children = [];
                      for (int i = 0; i < childrenFirstNames.length; i++) {
                        children.add(Child(
                          id: widget.userData.id + i.toString(),
                          firstName: childrenFirstNames[i].text,
                          lastName: childrenLastNames[i].text,
                        ));
                      }
                      UserData user = widget.userData.copyWith(
                        parentFirstName: parentFirstName.text,
                        parentLastName: parentLastName.text,
                        children: children,
                        member: member,
                        unlimitedMember: unlimitedMember,
                      );
                      FirestoreService().setData(
                        path: FirestorePath.user(widget.userData.id),
                        data: user.toMap(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Account has been successfully updated!"),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
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
