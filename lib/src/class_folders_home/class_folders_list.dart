import 'package:ffaclasses/src/class_feature/add_class.dart';
import 'package:ffaclasses/src/class_folders_home/class_folder.dart';
import 'package:ffaclasses/src/class_folders_home/class_types/advanced_classes.dart';
import 'package:ffaclasses/src/class_folders_home/class_types/foundation_classes.dart';
import 'package:ffaclasses/src/class_folders_home/class_types/mixed_classes.dart';
import 'package:ffaclasses/src/class_folders_home/class_types/youth_classes.dart';
import 'package:ffaclasses/src/settings/settings_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ClassFolders extends StatefulWidget {
  const ClassFolders({Key? key}) : super(key: key);
  static const routeName = '/classfolders';

  @override
  _ClassFoldersState createState() => _ClassFoldersState();
}

class _ClassFoldersState extends State<ClassFolders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forward Fencing Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.restorablePushNamed(context, AddClass.routeName);
        },
      ),
      body: Column(
        children: [
          Row(
            children: [
              ClassFolder(
                title: AppLocalizations.of(context)!.foundation,
                color: Colors.yellow,
                routeName: FoundationClasses.routeName,
              ),
              ClassFolder(
                title: AppLocalizations.of(context)!.youth,
                color: Colors.blue,
                routeName: YouthClasses.routeName,
              ),
            ],
          ),
          Row(
            children: [
              ClassFolder(
                title: AppLocalizations.of(context)!.mixed,
                color: Colors.green,
                routeName: MixedClasses.routeName,
              ),
              ClassFolder(
                title: AppLocalizations.of(context)!.advanced,
                color: Colors.orange,
                routeName: AdvancedClasses.routeName,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
