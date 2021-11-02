import 'package:flutter/material.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> itemList;
  final Function(List<String>) onSelectionChanged;
  final bool multi;
  const MultiSelectChip({
    Key? key,
    required this.itemList,
    required this.onSelectionChanged,
    this.multi = true,
  }) : super(key: key);
  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  String selectedChoice = "";
  List<String> selectedChoices = [];
  List<Widget> _buildChoiceList() {
    final List<Widget> choices = [];
    for (final item in widget.itemList) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item),
          selected: widget.multi
              ? selectedChoices.contains(item)
              : selectedChoice == item,
          onSelected: (selected) {
            if (widget.multi) {
              setState(() {
                selectedChoices.contains(item)
                    ? selectedChoices.remove(item)
                    : selectedChoices.add(item);
                widget.onSelectionChanged(selectedChoices);
              });
            } else {
              setState(() {
                selectedChoice = item;
              });
            }
          },
        ),
      ));
    }
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: _buildChoiceList(),
    );
  }
}
