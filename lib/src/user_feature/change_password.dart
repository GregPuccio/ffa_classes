import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/auth_feature/auth_service.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  static const routeName = 'changePassword';

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController oldPassword;
  late TextEditingController newPassword;
  late TextEditingController newPassword2;
  late bool obscure;

  @override
  void initState() {
    oldPassword = TextEditingController();
    newPassword = TextEditingController();
    newPassword2 = TextEditingController();
    obscure = true;
    super.initState();
  }

  Widget suffixIcon() {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off : Icons.visibility,
      ),
      onPressed: () {
        setState(() {
          obscure = !obscure;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Change Password"),
          ),
          body: Center(
            child: Container(
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).orientation == Orientation.landscape
                  ? 600
                  : null,
              child: ListView(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        "${userData.parentFirstName.substring(0, 1)}${userData.parentLastName.substring(0, 1)}",
                      ),
                    ),
                    title: Text(userData.emailAddress),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: oldPassword,
                            obscureText: obscure,
                            decoration: InputDecoration(
                              suffixIcon: suffixIcon(),
                              labelText: "Current password",
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              return oldPassword.text.length < 6
                                  ? "Please enter your current password"
                                  : null;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: newPassword,
                            obscureText: obscure,
                            decoration: InputDecoration(
                              labelText: "New password",
                              suffixIcon: suffixIcon(),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              return newPassword.text.length < 6
                                  ? "Password must be at least 6 characters"
                                  : null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: newPassword2,
                            decoration: InputDecoration(
                              labelText: "Repeat password",
                              suffixIcon: suffixIcon(),
                              border: const OutlineInputBorder(),
                            ),
                            obscureText: obscure,
                            validator: (value) {
                              return newPassword != newPassword2
                                  ? "New passwords need to match"
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkButton(
                    text: "Update password",
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await AuthService()
                            .updatePassword(oldPassword.text, newPassword.text);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
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
