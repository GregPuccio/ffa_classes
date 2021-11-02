import 'package:ffaclasses/src/class_feature/fclass.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:flutter/material.dart';

class MixedClasses extends StatefulWidget {
  const MixedClasses({Key? key}) : super(key: key);
  static const routeName = 'mixed';

  @override
  _MixedClassesState createState() => _MixedClassesState();
}

class _MixedClassesState extends State<MixedClasses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mixed Competitive Classes')),
      body: StreamBuilder<List<FClass>>(
        stream: FirestoreService().collectionStream(
          path: FirestorePath.mixedClasses(),
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
