import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/auth_feature/auth_service.dart';
import 'package:ffaclasses/src/constants/links.dart';
import 'package:ffaclasses/src/constants/theming/app_color.dart';
import 'package:ffaclasses/src/constants/theming/app_data.dart';
import 'package:ffaclasses/src/constants/widgets/buttons.dart';
import 'package:ffaclasses/src/constants/widgets/theme_popup_menu.dart';
import 'package:ffaclasses/src/feedback_feature/feedback_list.dart';
import 'package:ffaclasses/src/lessons_feature/edit_lesson_schedule.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:ffaclasses/src/user_feature/change_password.dart';
import 'package:ffaclasses/src/user_feature/edit_account.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'theme_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatefulWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);

  final ThemeController controller;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return Center(
          child: Container(
            alignment: Alignment.topCenter,
            width: MediaQuery.of(context).orientation == Orientation.landscape
                ? 600
                : null,
            child: ListView(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
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
                    title: const Text("Update Names"),
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
                Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: const Text("Update Password"),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ChangePassword.routeName,
                      );
                    },
                  ),
                ),
                if (userData.admin)
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("Update Lesson Availability"),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          EditLessonSchedule.routeName,
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A 3-way theme toggle switch that shows the scheme.
                        FlexThemeModeSwitch(
                          themeMode: widget.controller.themeMode,
                          onThemeModeChanged: widget.controller.setThemeMode,
                          flexSchemeData:
                              AppColor.schemes[widget.controller.schemeIndex],
                          optionButtonBorderRadius:
                              widget.controller.useSubThemes ? 12 : 4,
                          buttonOrder: FlexThemeModeButtonOrder.lightSystemDark,
                        ),
                        const SizedBox(height: 8),
                        // Theme popup menu button to select color scheme.
                        ThemePopupMenu(
                          contentPadding: EdgeInsets.zero,
                          schemeIndex: widget.controller.schemeIndex,
                          onChanged: (index) => setState(() {
                            widget.controller.setSchemeIndex(index);
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: const Text(
                    "ABOUT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: const Text("Privacy Policy"),
                    trailing: const Icon(Icons.launch),
                    onTap: () {
                      launch(privacyPolicy);
                    },
                  ),
                ),
                if (userData.admin)
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("View Feedback"),
                      trailing: const Icon(Icons.visibility),
                      onTap: () {
                        Navigator.pushNamed(context, FeedbackList.routeName);
                      },
                    ),
                  ),
                SecondaryButton(
                  text: "Logout",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text(
                            "Are you sure you would like to log out?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel")),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                AuthService().signOut();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "You have successfully logged out!"),
                                  ),
                                );
                              },
                              child: const Text("Log Out")),
                        ],
                      ),
                    );
                  },
                ),
                TextButton(
                  child: const Text("Acknowledgements"),
                  onPressed: () {
                    showLicensePage(
                      context: context,
                      applicationName: AppData.name,
                      applicationVersion: AppData.version,
                      applicationIcon: Image.asset(AppData.icon, width: 100),
                      applicationLegalese: AppData.author,
                    );
                  },
                ),
              ],
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
