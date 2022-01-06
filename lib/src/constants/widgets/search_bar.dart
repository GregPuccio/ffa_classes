import 'package:ffaclasses/src/fencer_feature/fencer.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget searchBar(TextEditingController controller, Color cardColor,
    {String text = 'Search by first name',
    bool autoComplete = false,
    void Function(Fencer result)? onResult}) {
  Widget withAutoComplete() {
    List<Fencer> fencers = [];
    return Autocomplete(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isNotEmpty) {
          fencers =
              await FirestoreService().userChildrentoFencerCollectionFuture(
            path: FirestorePath.users(),
            builder: (map, docID) => Fencer.fromUserMap(map!),
            queryBuilder: (query) => query
                .orderBy('parentLastName')
                .where('searchTerms',
                    arrayContains: textEditingValue.text.toLowerCase())
                .where('admin', isEqualTo: false)
                .limit(20),
          );

          return fencers.map((e) => e.name);

          // if (textEditingValue.text == '') {
          //   return ['aa', 'bb', 'cc', 'aa', 'bb', 'cc'];
          // }
          // return ['aa', 'bb', 'cc', 'aa', 'bb', 'cc']
          //     .where((String option) {
          //   return option
          //       .toString()
          //       .contains(textEditingValue.text.toLowerCase());
          // });
        } else {
          return [''];
        }
      },
      onSelected: (String name) {
        if (onResult != null) {
          onResult(fencers.firstWhere((fencer) => fencer.name == name));
        }
      },
    );
  }

  Widget withoutAutoComplete = Container(
    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
    child: TextField(
      decoration: InputDecoration(
        fillColor: cardColor,
        filled: true,
        hintText: text,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.search),
      ),
      controller: controller,
    ),
  );
  return PreferredSize(
    preferredSize: const Size.fromHeight(65),
    child: autoComplete ? withAutoComplete() : withoutAutoComplete,
  );
}
