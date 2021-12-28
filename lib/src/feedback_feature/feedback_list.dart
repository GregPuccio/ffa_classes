import 'package:ffaclasses/src/feedback_feature/feedback_model.dart';
import 'package:ffaclasses/src/firebase/firestore_path.dart';
import 'package:ffaclasses/src/firebase/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedbackList extends StatelessWidget {
  const FeedbackList({Key? key}) : super(key: key);
  static const routeName = '/feedback';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback List"),
      ),
      body: StreamBuilder<List<FeedbackModel>>(
          stream: FirestoreService().collectionStream(
            path: FirestorePath.feedbacks(),
            builder: (map, docID) =>
                FeedbackModel.fromMap(map!).copyWith(id: docID),
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<FeedbackModel> feedbacks = snapshot.data!;
              feedbacks.sort(
                  (a, b) => a.feedbackType.name.compareTo(b.feedbackType.name));
              return ListView.builder(
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    FeedbackModel feedback = feedbacks[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: () => openImage(context, feedback),
                        leading: InkWell(
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(feedback.snapshotUrl),
                          ),
                        ),
                        title: Column(
                          children: [
                            Text(feedbackTypeString(feedback.feedbackType)),
                            Text(feedback.text)
                          ],
                        ),
                        subtitle: Text(
                          "${feedback.submittedBy} | ${DateFormat('M/d hh:m aa').format(feedback.submittedWhen)}",
                        ),
                        trailing: !feedback.incorporated
                            ? TextButton(
                                child: const Icon(Icons.check_box),
                                onPressed: () {
                                  FirestoreService().updateData(
                                    path: FirestorePath.feedback(feedback.id),
                                    data: feedback
                                        .copyWith(incorporated: true)
                                        .toMap(),
                                  );
                                },
                              )
                            : TextButton(
                                child: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  FirestoreService().deleteData(
                                    path: FirestorePath.feedback(feedback.id),
                                  );
                                },
                              ),
                      ),
                    );
                  });
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

void openImage(BuildContext context, FeedbackModel feedback) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          feedbackTypeString(feedback.feedbackType),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(feedback.text),
              Image.network(
                feedback.snapshotUrl,
                height: 600,
                width: 500,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
