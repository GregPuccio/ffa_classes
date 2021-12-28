import 'dart:typed_data';

import 'package:ffaclasses/src/feedback_feature/feedback_model.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  Reference _storageReference() {
    return FirebaseStorage.instance.ref();
  }

  Future addImage(FeedbackModel feedbackModel, Uint8List data) async {
    final TaskSnapshot snapshot = await _storageReference()
        .child("images/${feedbackModel.submittedWhen.millisecondsSinceEpoch}")
        .putData(data)
        .catchError((val) {
      return 'AN ERROR HAS OCCURED';
    });
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    feedbackModel = feedbackModel.copyWith(snapshotUrl: downloadUrl);
    await FirestoreService().setData(
      path: FirestorePath.feedback(
          feedbackModel.submittedWhen.millisecondsSinceEpoch.toString()),
      data: feedbackModel.toMap(),
    );
    return 'Image has uploaded sucessfully.';
  }

  Future removeImage(FeedbackModel feedbackModel) async {
    try {
      await _storageReference()
          .child("images/${feedbackModel.submittedWhen.millisecondsSinceEpoch}")
          .delete();
      await FirestoreService().deleteData(path: feedbackModel.id);
      return 'Image has been removed successfully.';
    } catch (e) {
      return 'AN ERROR HAS OCCURRED';
    }
  }
}
