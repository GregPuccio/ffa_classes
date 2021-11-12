import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider<User?>(
    (ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final databaseProvider = Provider<FirestoreService>((ref) {
  final auth = ref.watch(authStateChangesProvider);

  if (auth.asData?.value?.uid != null) {
    return FirestoreService();
  }
  throw UnimplementedError();
});

final userDataProvider = StreamProvider<UserData?>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final database = ref.watch(databaseProvider);
  return database.documentStream(
    path: FirestorePath.user(auth.asData!.value!.uid),
    builder: (map, docID) {
      if (map != null) {
        return UserData.fromMap(map).copyWith(id: docID);
      } else {
        return null;
      }
    },
  );
});
