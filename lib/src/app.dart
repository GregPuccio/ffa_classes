import 'package:ffaclasses/src/auth_feature/auth.dart';
import 'package:ffaclasses/src/class_feature/add_class.dart';
import 'package:ffaclasses/src/class_feature/fclass_details.dart';
import 'package:ffaclasses/src/class_list_wrapper/class_list_wrapper.dart';
import 'package:ffaclasses/src/fencer_feature/fencer_search.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/user_feature/create_account.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'camp_feature/add_camp.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
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
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case FClassDetails.routeName:
                    return const FClassDetails();
                  case AddClass.routeName:
                    return const AddClass();
                  case AddCamp.routeName:
                    return const AddCamp();
                  case FencerSearch.routeName:
                    return const FencerSearch();
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  default:
                    return const AuthWrapper();
                }
              },
            );
          },
        );
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
