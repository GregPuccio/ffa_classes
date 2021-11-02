import 'package:flutter/material.dart';

class ClassFolder extends StatelessWidget {
  final String title;
  final Color color;
  final String routeName;
  const ClassFolder({
    Key? key,
    required this.title,
    required this.color,
    required this.routeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
          color: color,
          onPressed: () {
            Navigator.restorablePushNamed(context, routeName);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                title,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
