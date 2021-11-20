import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
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
  late TextEditingController firstName;
  late TextEditingController lastName;
  late bool parentSignUp;
  late TextEditingController parentFirstName;
  late TextEditingController parentLastName;
  @override
  void initState() {
    firstName = TextEditingController();
    lastName = TextEditingController();
    parentSignUp = false;
    parentFirstName = TextEditingController();
    parentLastName = TextEditingController();
    super.initState();
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
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "You're almost done!",
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    textCapitalization: TextCapitalization.words,
                    controller: firstName,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "First Name",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    textCapitalization: TextCapitalization.words,
                    controller: lastName,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Last Name",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CheckboxListTile(
                    title: const Text(
                        "Are you a parent registering for your child?"),
                    value: parentSignUp,
                    onChanged: (val) {
                      setState(() {
                        parentSignUp = !parentSignUp;
                      });
                    },
                  ),
                ),
                if (parentSignUp)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      textCapitalization: TextCapitalization.words,
                      controller: parentFirstName,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Parent's First Name",
                      ),
                    ),
                  ),
                if (parentSignUp)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      textCapitalization: TextCapitalization.words,
                      controller: parentLastName,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Parent's Last Name",
                      ),
                    ),
                  ),
              ],
            ),
          ),
          InkButton(
            text: "Complete setup",
            onPressed: () {
              if (firstName.text.isEmpty ||
                  lastName.text.isEmpty ||
                  (parentSignUp &&
                      (parentFirstName.text.isEmpty ||
                          parentLastName.text.isEmpty))) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text("Please make sure all fields are filled in!")));
              } else {
                UserData user = UserData(
                  id: 'id',
                  admin: false,
                  firstName: firstName.text,
                  lastName: lastName.text,
                  emailAddress: widget.user.email!,
                  parentSignUp: parentSignUp,
                  parentFirstName: parentFirstName.text,
                  parentLastName: parentLastName.text,
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
