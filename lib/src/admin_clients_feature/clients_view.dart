import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/constants/widgets/search_bar.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/screen_arguments/screen_arguments.dart';
import 'package:ffaclasses/src/user_feature/edit_account.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientsView extends ConsumerStatefulWidget {
  const ClientsView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClientsViewState();
}

class _ClientsViewState extends ConsumerState<ClientsView> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget whenData(UserData? userData) {
      return StreamBuilder<List<UserData>>(
        stream: FirestoreService().collectionStream(
          path: FirestorePath.users(),
          builder: (map, docID) => UserData.fromMap(map!).copyWith(id: docID),
          queryBuilder: (query) => query
              .orderBy('parentLastName')
              .where('searchTerms',
                  arrayContains: controller.text.toLowerCase())
              .where('admin', isEqualTo: false)
              .limit(20),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<UserData> users = snapshot.data!;
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    searchBar(controller, Theme.of(context).cardColor),
                    Flexible(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          UserData user = users[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                  "${user.parentFirstName} ${user.parentLastName}"),
                              subtitle: Text(user.childrenFirstNames),
                              trailing: const Icon(Icons.edit),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  EditAccount.routeName,
                                  arguments: ScreenArgs(userData: user),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    }

    return ref.watch(userDataProvider).when(
          data: whenData,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (object, stackTrace) => const AuthWrapper(),
        );
  }
}
