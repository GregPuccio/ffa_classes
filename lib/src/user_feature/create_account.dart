import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/user_feature/child.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountSetup extends StatefulWidget {
  final User user;
  const AccountSetup({Key? key, required this.user}) : super(key: key);

  @override
  _AccountSetupState createState() => _AccountSetupState();
}

class _AccountSetupState extends State<AccountSetup> {
  late TextEditingController parentFirstName;
  late TextEditingController parentLastName;
  late List<TextEditingController> childrenFirstNames;
  late List<TextEditingController> childrenLastNames;
  @override
  void initState() {
    childrenFirstNames = [];
    childrenLastNames = [];

    parentFirstName = TextEditingController();
    parentLastName = TextEditingController();
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
        title: const Text("Account Setup"),
      ),
      body: Column(
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
                                textCapitalization: TextCapitalization.words,
                                controller: childrenFirstNames[index],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "First Name",
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                textCapitalization: TextCapitalization.words,
                                controller: childrenLastNames[index],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Last Name",
                                ),
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
            text: "Complete setup",
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
                    id: 'id',
                    firstName: childrenFirstNames[i].text,
                    lastName: childrenLastNames[i].text,
                  ));
                }
                UserData user = UserData(
                  id: 'id',
                  invoicingKey: '',
                  invoices: [],
                  admin: false,
                  emailAddress: widget.user.email!,
                  parentFirstName: parentFirstName.text,
                  parentLastName: parentLastName.text,
                  children: children,
                  member: false,
                  unlimitedMember: false,
                  availability: [],
                );
                FirestoreService().setData(
                  path: FirestorePath.user(widget.user.uid),
                  data: user.toMap(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
