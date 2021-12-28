import 'dart:convert';

import 'package:ffaclasses/src/constants/enums.dart';

String feedbackTypeString(FeedbackType type) {
  switch (type) {
    case FeedbackType.bugReport:
      return "Bug Report";
    case FeedbackType.featureRequest:
      return "Feature Request";
  }
}

class FeedbackModel {
  final String id;
  final String text;
  final FeedbackType feedbackType;
  final String submittedBy;
  final DateTime submittedWhen;
  final bool incorporated;
  final String snapshotUrl;
  FeedbackModel({
    required this.id,
    required this.text,
    required this.feedbackType,
    required this.submittedBy,
    required this.submittedWhen,
    required this.incorporated,
    required this.snapshotUrl,
  });

  FeedbackModel copyWith({
    String? id,
    String? text,
    FeedbackType? feedbackType,
    String? submittedBy,
    DateTime? submittedWhen,
    bool? incorporated,
    String? snapshotUrl,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      text: text ?? this.text,
      feedbackType: feedbackType ?? this.feedbackType,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedWhen: submittedWhen ?? this.submittedWhen,
      incorporated: incorporated ?? this.incorporated,
      snapshotUrl: snapshotUrl ?? this.snapshotUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'feedbackType': feedbackType.index,
      'submittedBy': submittedBy,
      'submittedWhen': submittedWhen.millisecondsSinceEpoch,
      'incorporated': incorporated,
      'snapshotUrl': snapshotUrl,
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      feedbackType: FeedbackType.values[map['feedbackType'] ?? 0],
      submittedBy: map['submittedBy'] ?? '',
      submittedWhen: DateTime.fromMillisecondsSinceEpoch(map['submittedWhen']),
      incorporated: map['incorporated'] ?? false,
      snapshotUrl: map['snapshotUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory FeedbackModel.fromJson(String source) =>
      FeedbackModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FeedbackModel(id: $id, text: $text, feedbackType: $feedbackType, submittedBy: $submittedBy, submittedWhen: $submittedWhen, incorporated: $incorporated, snapshotUrl: $snapshotUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FeedbackModel &&
        other.id == id &&
        other.text == text &&
        other.feedbackType == feedbackType &&
        other.submittedBy == submittedBy &&
        other.submittedWhen == submittedWhen &&
        other.incorporated == incorporated &&
        other.snapshotUrl == snapshotUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        feedbackType.hashCode ^
        submittedBy.hashCode ^
        submittedWhen.hashCode ^
        incorporated.hashCode ^
        snapshotUrl.hashCode;
  }
}
