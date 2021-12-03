import 'package:ffaclasses/src/auth_feature/auth_service.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:ffaclasses/src/user_feature/edit_account.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
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
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: const Text(
                      "ACCOUNT",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("Edit Names"),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          EditAccount.routeName,
                          arguments: ScreenArgs(userData: userData),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: const Text(
                      "THEMING",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<ThemeMode>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      // Read the selected themeMode from the controller
                      value: controller.themeMode,
                      // Call the updateThemeMode method any time the user selects a theme.
                      onChanged: controller.updateThemeMode,
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System Theme'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light Theme'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark Theme'),
                        ),
                      ],
                    ),
                  ),
                  // Container(
                  //   margin: const EdgeInsets.all(10),
                  //   child: const Text(
                  //     "ADMIN",
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  // InkButton(
                  //   text: "Reformat",
                  //   onPressed: () async {
                  //     List<UserData> users = await FirestoreService()
                  //         .collectionFuture(
                  //             path: FirestorePath.users(),
                  //             builder: (map, docID) =>
                  //                 UserData.fromMap(map!).copyWith(id: docID));
                  //     for (var user in users) {
                  //       Child child = Child(
                  //           id: user.id + "0",
                  //           firstName: user.firstName,
                  //           lastName: user.lastName);
                  //       UserData userData = user.copyWith(children: [child]);
                  //       FirestoreService().updateData(
                  //         path: FirestorePath.user(user.id),
                  //         data: userData.toMap(),
                  //       );
                  //     }
                  //   },
                  // ),
                  SecondaryButton(
                    text: "Logout",
                    onPressed: () {
                      Navigator.pop(context);
                      AuthService().signOut();
                    },
                  ),
                  TextButton(
                    child: const Text("Acknowledgements"),
                    onPressed: () {
                      showLicensePage(
                        context: context,
                        applicationName: "FFA Classes",
                        applicationVersion: "0.14-beta",
                        applicationIcon:
                            Image.asset('assets/images/logo.png', width: 100),
                      );
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
