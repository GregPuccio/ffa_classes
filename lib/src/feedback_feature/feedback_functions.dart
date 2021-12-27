import 'package:feedback/feedback.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/feedback_feature/feedback_model.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:ffaclasses/src/user_feature/user_data.dart';
import 'package:flutter/material.dart';

/// Shows an [AlertDialog] with the given feedback.
/// This is useful for debugging purposes.
void alertFeedbackFunction(
  BuildContext outerContext,
  UserFeedback feedback,
  UserData userData,
) {
  showDialog<void>(
    context: outerContext,
    builder: (context) {
      return AlertDialog(
        title: Text(feedback.text),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (feedback.extra != null) Text(feedback.extra!.toString()),
              Image.memory(
                feedback.screenshot,
                height: 600,
                width: 500,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Send'),
            onPressed: () {
              FeedbackModel feedbackModel = FeedbackModel(
                id: 'id',
                text: feedback.text,
                feedbackType:
                    feedback.extra?['type'] ?? FeedbackType.featureRequest,
                submittedBy:
                    "${userData.parentFirstName} ${userData.parentLastName}",
                submittedWhen: DateTime.now(),
                incorporated: false,
              );
              FirestoreService().addData(
                path: FirestorePath.feedbacks(),
                data: feedbackModel.toMap(),
              );
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}
