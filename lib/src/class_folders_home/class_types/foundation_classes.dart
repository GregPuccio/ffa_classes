import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:flutter/material.dart';

class FoundationClasses extends StatefulWidget {
  const FoundationClasses({Key? key}) : super(key: key);
  static const routeName = 'foundation';

  @override
  _FoundationClassesState createState() => _FoundationClassesState();
}

class _FoundationClassesState extends State<FoundationClasses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foundation Classes')),
      body: StreamBuilder<List<FClass>>(
        stream: FirestoreService().collectionStream(
          path: FirestorePath.foundationClasses(),
          builder: (map, docID) => FClass.fromMap(map!),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<FClass> classes = snapshot.data!;
            return ListView.builder(
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  FClass fclass = classes[index];
                  return Card(
                    child: ListTile(
                      title: Text(fclass.title),
                      subtitle: Text(fclass.description),
                    ),
                  );
                });
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
