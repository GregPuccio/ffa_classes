import 'package:ffaclasses/src/settings/theme_controller.dart';
import 'package:ffaclasses/src/settings/theme_service.dart';
import 'package:ffaclasses/src/settings/theme_service_hive.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final ThemeService themeService = ThemeServiceHive('flex_scheme_box_4');
  // Initialize the theme service.
  await themeService.init();
  // Create a ThemeController that uses the ThemeService.
  final ThemeController themeController = ThemeController(themeService);
  // Load all the preferred theme settings, while the app is loading, before
  // MaterialApp is created. This prevents a sudden theme change when the app
  // is first displayed.
  await themeController.loadAll();
  // Run the app and pass in the ThemeController. The app listens to the
  // ThemeController for changes.

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(
    ProviderScope(child: MyApp(themeController: themeController)),
  );
}
