import 'package:feedback/feedback.dart';
import 'package:ffaclasses/src/auth_feature/auth.dart';
import 'package:ffaclasses/src/class_feature/add_class.dart';
import 'package:ffaclasses/src/camp_feature/edit_camp.dart';
import 'package:ffaclasses/src/class_feature/edit_class.dart';
import 'package:ffaclasses/src/class_feature/fclass_details.dart';
import 'package:ffaclasses/src/class_list_wrapper/class_list_wrapper.dart';
import 'package:ffaclasses/src/constants/theming/app_color.dart';
import 'package:ffaclasses/src/constants/theming/app_data.dart';
import 'package:ffaclasses/src/feedback_feature/custom_feedback.dart';
import 'package:ffaclasses/src/feedback_feature/feedback_list.dart';
import 'package:ffaclasses/src/fencer_feature/fencer_search.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:ffaclasses/src/user_feature/change_password.dart';
import 'package:ffaclasses/src/user_feature/create_account.dart';
import 'package:ffaclasses/src/user_feature/edit_account.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'camp_feature/add_camp.dart';
import 'settings/theme_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.themeController,
  }) : super(key: key);
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    Map<ShortcutActivator, Intent> shortcuts =
        Map.from(WidgetsApp.defaultShortcuts);
    shortcuts.remove(const SingleActivator(LogicalKeyboardKey.space));
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return AnimatedBuilder(
      animation: themeController,
      builder: (BuildContext context, Widget? child) {
        return BetterFeedback(
            child: MaterialApp(
              shortcuts: shortcuts,
              // Providing a restorationScopeId allows the Navigator built by the
              // MaterialApp to restore the navigation stack when a user leaves and
              // returns to the app after it has been killed while running in the
              // background.
              restorationScopeId: 'app',
              supportedLocales: const [
                Locale('en', ''), // English, no country code
              ],

              // Define a light and dark color theme. Then, read the user's
              // preferred ThemeMode (light, dark, or system default) from the
              // SettingsController to display the correct theme.
              theme: FlexThemeData.light(
                // We moved the definition of the list of color schemes to use into
                // a separate static class and list. We use the theme controller
                // to change the index of used color scheme from the list.
                colors: AppColor.schemes[themeController.schemeIndex].light,
                // Here we use another surface blend mode, where the scaffold
                // background gets a strong blend. This type is commonly used
                // on web/desktop when you wrap content on the scaffold in a
                // card that has a lighter background.
                surfaceMode: FlexSurfaceMode.highScaffoldLowSurfaces,
                // Our content is not all wrapped in cards in this demo, so
                // we keep the blend level fairly low for good contrast.
                blendLevel: 5,
                appBarElevation: 0.5,
                useSubThemes: themeController.useSubThemes,
                // In this example we use the values for visual density and font
                // from a single static source, so we can change it easily there.
                visualDensity: AppData.visualDensity,
                fontFamily: AppData.font,
              ),
              darkTheme: FlexThemeData.dark(
                colors: AppColor.schemes[themeController.schemeIndex].dark,
                surfaceMode: FlexSurfaceMode.highScaffoldLowSurfaces,
                // We go with a slightly stronger blend in dark mode. It is worth
                // noticing, that in light mode, the alpha value used for the blends
                // is the blend level value, but in dark mode it is 2x this value.
                // Visually they match fairly well, but it depends on how saturated
                // your dark mode primary color is.
                blendLevel: 7,
                appBarElevation: 0.5,
                useSubThemes: themeController.useSubThemes,
                visualDensity: AppData.visualDensity,
                fontFamily: AppData.font,
              ),
              themeMode: themeController.themeMode,
              debugShowCheckedModeBanner: false,

              // Define a function to handle named routes in order to support
              // Flutter web url navigation and deep linking.
              onGenerateRoute: (RouteSettings routeSettings) {
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) {
                    if (routeSettings.name != null) {
                      Uri uri = Uri.parse(routeSettings.name!);
                      if (uri.pathSegments.length == 2 &&
                          uri.pathSegments.first == FClassDetails.routeName) {
                        String id = uri.pathSegments[1];
                        return FClassDetails(id: id);
                      }
                    }
                    switch (routeSettings.name) {
                      case AddClass.routeName:
                        return const AddClass();
                      case EditClass.routeName:
                        return EditClass(
                            args: routeSettings.arguments as ScreenArgs);
                      case AddCamp.routeName:
                        return const AddCamp();
                      case EditCamp.routeName:
                        return EditCamp(
                            args: routeSettings.arguments as ScreenArgs);
                      case FencerSearch.routeName:
                        return const FencerSearch();
                      case SettingsView.routeName:
                        return SettingsView(controller: themeController);
                      case EditAccount.routeName:
                        return EditAccount(
                          userData:
                              (routeSettings.arguments as ScreenArgs).userData!,
                        );
                      case ChangePassword.routeName:
                        return const ChangePassword();
                      case FeedbackList.routeName:
                        return const FeedbackList();
                      default:
                        return const AuthWrapper();
                    }
                  },
                );
              },
            ),
            feedbackBuilder: (context, onSubmit) =>
                CustomFeedbackForm(onSubmit: onSubmit));
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget whenData(User? user) {
      if (user != null) {
        return LoggedInWrapper(user: user);
      } else {
        return const LoginScreen();
      }
    }

    return ref.watch(authStateChangesProvider).when(
          data: whenData,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (object, stackTrace) => Center(
            child: Text(
              "Error",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        );
  }
}

class LoggedInWrapper extends ConsumerWidget {
  final User user;
  const LoggedInWrapper({Key? key, required this.user}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return const ClassListWrapper();
      } else {
        return AccountSetup(user: user);
      }
    }

    return ref.watch(userDataProvider).when(
          data: whenData,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (object, stackTrace) => Center(
            child: Text(
              "Error",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        );
  }
}
