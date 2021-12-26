import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/user_feature/child.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Account"),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).orientation == Orientation.landscape
              ? 600
              : null,
          child: Column(
            children: [
              Flexible(
                child: ListView(
                  children: [
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
                                childrenFirstNames.add(TextEditingController());
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
                    UserData user = UserData(
                      id: widget.userData.id,
                      admin: false,
                      emailAddress: widget.userData.emailAddress,
                      parentFirstName: parentFirstName.text,
                      parentLastName: parentLastName.text,
                      children: children,
                      member: widget.userData.member,
                      unlimitedMember: widget.userData.member,
                    );
                    FirestoreService().setData(
                      path: FirestorePath.user(widget.userData.id),
                      data: user.toMap(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Account has been successfully updated!"),
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
}
