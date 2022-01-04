import 'package:feedback/feedback.dart';
import 'package:ffaclasses/main.dart';
import 'package:ffaclasses/src/admin_clients_feature/clients_view.dart';
import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/camp_feature/add_camp.dart';
import 'package:ffaclasses/src/class_feature/add_class.dart';
import 'package:ffaclasses/src/class_list_wrapper/class_list_views/class_calendar.dart';
import 'package:ffaclasses/src/class_list_wrapper/class_list_views/class_list.dart';
import 'package:ffaclasses/src/feedback_feature/feedback_functions.dart';
import 'package:ffaclasses/src/invoice_feature/client_invoicing.dart';
import 'package:ffaclasses/src/lessons_feature/lesson_calendar.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/settings/settings_view.dart';
import 'package:ffaclasses/src/strip_coaching_feature/add_strip_coaching.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeStructure extends StatefulWidget {
  const HomeStructure({Key? key}) : super(key: key);
  static const routeName = 'classList';

  @override
  _HomeStructureState createState() => _HomeStructureState();
}

class _HomeStructureState extends State<HomeStructure> {
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
    switch (index) {
      case 0:
        return Column(
          children: [
            ListTile(
              title: Text(
                "Group Attendance",
                style: Theme.of(context).textTheme.headline6,
              ),
              trailing: IconButton(
                onPressed: changeView,
                icon: Icon(calendar ? Icons.list : Icons.event),
              ),
            ),
            Flexible(
              child:
                  calendar ? const ClassCalendarView() : const ClassListView(),
            ),
          ],
        );
      case 1:
        return const LessonCalendarView();
      case 2:
        if (admin) {
          return const ClientsView();
        } else {
          return const ClientInvoicing();
        }
      case 3:
        return SettingsView(controller: themeController);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      if (userData != null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Forward Fencing Academy'),
            actions: [
              IconButton(
                icon: const Icon(Icons.feedback),
                onPressed: () {
                  BetterFeedback.of(context).show(
                    (feedback) async {
                      alertFeedbackFunction(
                        context,
                        feedback,
                        userData,
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
                      PopupMenuItem(
                        child: ListTile(
                          title: const Text('Add Strip Coaching'),
                          onTap: () {
                            Navigator.restorablePushNamed(
                                context, AddStripCoaching.routeName);
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
                  icon: Icon(Icons.people), label: 'Group'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Private'),
              BottomNavigationBarItem(
                  icon:
                      Icon(userData.admin ? Icons.attach_money : Icons.payment),
                  label: userData.admin ? 'Clients' : 'Payments'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: 'Settings'),
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
