import 'package:ffaclasses/src/app.dart';
import 'package:ffaclasses/src/riverpod/providers.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientsView extends ConsumerWidget {
  const ClientsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget whenData(UserData? userData) {
      return Container();
    }

    return ref.watch(userDataProvider).when(
          data: whenData,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (object, stackTrace) => const AuthWrapper(),
        );
  }
}
