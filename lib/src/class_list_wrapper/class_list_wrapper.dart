import 'package:ffaclasses/src/camp_feature/add_camp.dart';
import 'package:ffaclasses/src/class_feature/add_class.dart';
import 'package:ffaclasses/src/class_list_wrapper/class_list_views/calendar_view.dart';
import 'package:ffaclasses/src/class_list_wrapper/class_list_views/list_view.dart';
import 'package:ffaclasses/src/invoice_feature/invoice_example.dart';
// import 'package:ffaclasses/src/invoice_feature/invoice_example.dart';
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

  Widget getBody() {
    if (index == 0) {
      return calendar ? const ClassCalendarView() : const ClassListView();
    } else {
      return const InvoiceExample();
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
            ],
          ),
          floatingActionButton: userData.admin
              ?
              // Row(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: [
              PopupMenuButton(
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
              // ,
              // FloatingActionButton(
              //   heroTag: 'invoice',
              //   onPressed: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => const InvoiceExample()));
              //   },
              // ),
              //   ],
              // )
              : null,
          body: getBody(),
          bottomNavigationBar: BottomNavigationBar(
            onTap: changeTab,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Classes'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.payment), label: 'Payments'),
            ],
          ),
        );
      } else {
        return Center(
          child: Text(
            "Error",
            style: Theme.of(context).textTheme.headline6,
          ),
        );
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
