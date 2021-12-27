import 'package:feedback/feedback.dart';
import 'package:ffaclasses/src/constants/enums.dart';
import 'package:ffaclasses/src/feedback_feature/feedback_model.dart';
import 'package:flutter/material.dart';

/// A form that prompts the user for the type of feedback they want to give,
/// free form text feedback, and a sentiment rating.
/// The submit button is disabled until the user provides the feedback type. All
/// other fields are optional.
class CustomFeedbackForm extends StatefulWidget {
  const CustomFeedbackForm({Key? key, required this.onSubmit})
      : super(key: key);

  final OnSubmit onSubmit;

  @override
  _CustomFeedbackFormState createState() => _CustomFeedbackFormState();
}

class _CustomFeedbackFormState extends State<CustomFeedbackForm> {
  FeedbackType? _feedbackType;
  String? _feedbackText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            children: [
              const Text('Please choose your feedback type:'),
              Row(
                children: [
                  DropdownButton<FeedbackType>(
                    value: _feedbackType,
                    items: FeedbackType.values
                        .map(
                          (type) => DropdownMenuItem<FeedbackType>(
                            child: Text(feedbackTypeString(type)),
                            value: type,
                          ),
                        )
                        .toList(),
                    onChanged: (feedbackType) =>
                        setState(() => _feedbackType = feedbackType),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('What is your feedback?'),
              const SizedBox(height: 8),
              TextField(
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (newFeedback) => _feedbackText = newFeedback,
                maxLines: 5,
              ),
            ],
          ),
        ),
        TextButton(
          // disable this button until the user has specified a feedback type
          onPressed: _feedbackType != null
              ? () {
                  widget.onSubmit(
                    _feedbackText ?? '',
                    extras: {'type': _feedbackType},
                  );
                  // await Future.delayed(const Duration(seconds: 1));
                  // Navigator.pop(context);
                }
              : null,
          child: const Text('Submit'),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
