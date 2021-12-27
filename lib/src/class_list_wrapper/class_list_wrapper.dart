import 'package:feedback/feedback.dart';
import 'package:ffaclasses/src/admin_clients_feature/clients_view.dart';
import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/camp_feature/add_camp.dart';
import 'package:ffaclasses/src/class_feature/add_class.dart';
import 'package:ffaclasses/src/class_list_wrapper/class_list_views/calendar_view.dart';
import 'package:ffaclasses/src/class_list_wrapper/class_list_views/list_view.dart';
import 'package:ffaclasses/src/feedback_feature/n_feedback_functions.dart';
import 'package:ffaclasses/src/invoice_feature/client_invoicing.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/settings/settings_view.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassListWrapper extends StatefulWidget {
  const ClassListWrapper({Key? key}) : super(key: key);
  static const routeName = 'classList';

  @override
  _ClassListWrapperState createState() => _ClassListWrapperState();
}

class _ClassListWrapperState extends State<ClassListWrapper> {
  bool calendar = false;
  int index = 0;

  void changeTab(int newIndex) {
    if (index != newIndex) {
      setState(() {
        index = newIndex;
      });
    }
  }

  void changeView() {
    setState(() {
      calendar = !calendar;
    });
  }

  Widget getBody(bool admin) {
    if (index == 0) {
      return calendar ? const ClassCalendarView() : const ClassListView();
    } else if (index == 1) {
      // if (admin) {
      //   return const AdminInvoicing();
      // } else {
      return const ClientInvoicing();
      // }
    } else {
      return const ClientsView();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Forward Fencing Classes'),
            actions: [
              if (index == 0)
                IconButton(
                  onPressed: changeView,
                  icon: Icon(calendar ? Icons.home : Icons.calendar_today),
                ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Navigate to the settings page. If the user leaves and returns
                  // to the app after it has been killed while running in the
                  // background, the navigation stack is restored.
                  Navigator.restorablePushNamed(
                      context, SettingsView.routeName);
                },
              ),
              if (userData.admin)
                ElevatedButton(
                  child: const Text('Provide feedback'),
                  onPressed: () {
                    BetterFeedback.of(context).show(
                      (feedback) async {
                        // upload to server, share whatever
                        // for example purposes just show it to the user
                        alertFeedbackFunction(
                          context,
                          feedback,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
          floatingActionButton: userData.admin && index == 0
              ? PopupMenuButton(
                  child: const FloatingActionButton(
                      onPressed: null, child: Icon(Icons.add)),
                  itemBuilder: (_) {
                    return [
                      PopupMenuItem(
                        child: ListTile(
                          title: const Text('Add Classes'),
                          onTap: () {
                            Navigator.restorablePushNamed(
                                context, AddClass.routeName);
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: ListTile(
                          title: const Text('Add a Camp'),
                          onTap: () {
                            Navigator.restorablePushNamed(
                                context, AddCamp.routeName);
                          },
                        ),
                      ),
                    ];
                  })
              : null,
          body: getBody(userData.admin),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: changeTab,
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.list), label: 'Classes'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.payment), label: 'Invoicing'),
              if (userData.admin)
                const BottomNavigationBarItem(
                    icon: Icon(Icons.people), label: 'Clients'),
            ],
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
