import 'package:flutter/material.dart';

class InkButton extends StatelessWidget {
  final String text;
  final Function? onPressed;
  final bool active;
  const InkButton({
    Key? key,
    this.text = 'Next',
    this.onPressed,
    this.active = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 55, maxWidth: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            colors: active
                ? [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.secondaryContainer
                  ]
                : [
                    Colors.grey,
                    Colors.blueGrey,
                  ],
          ),
          boxShadow: kElevationToShadow[1],
        ),
        margin: const EdgeInsets.all(10.0),
        child: MaterialButton(
          onPressed: active ? onPressed as void Function()? : null,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final Function? onPressed;
  final bool active;
  final Color? activeColor;
  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.active = true,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = active
        ? activeColor ?? Theme.of(context).colorScheme.secondaryContainer
        : Colors.grey;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 55, maxWidth: 400),
        margin: const EdgeInsets.all(10.0),
        child: OutlinedButton(
          clipBehavior: Clip.antiAlias,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 1,
          ),
          onPressed: active ? onPressed as void Function()? : null,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 20,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
