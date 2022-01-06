import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

/// Builds an event text widget in order to put it in a week view.
Widget defaultEventTextBuilder(FlutterWeekViewEvent event, BuildContext context,
    DayView dayView, double height, double width) {
  List<TextSpan> text = [
    TextSpan(
      text: event.title,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    const TextSpan(
      text: '\n\n',
    ),
    TextSpan(
      text: event.description,
    ),
  ];

  return RichText(
    text: TextSpan(
      children: text,
      style: event.textStyle,
    ),
  );
}
