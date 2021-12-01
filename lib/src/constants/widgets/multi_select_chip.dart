import 'package:flutter/material.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> itemList;
  final Function(List<String>) onSelectionChanged;
  final List<String> initialChoices;
  final bool multi;
  final bool horizScroll;
  const MultiSelectChip({
    Key? key,
    required this.itemList,
    required this.onSelectionChanged,
    this.initialChoices = const [],
    this.multi = true,
    this.horizScroll = false,
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
          padding: const EdgeInsets.all(8),
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
                widget.onSelectionChanged([item]);
              });
            }
          },
        ),
      ));
    }
    return choices;
  }

  @override
  void initState() {
    if (widget.initialChoices.isNotEmpty) {
      if (widget.multi) {
        selectedChoices = widget.initialChoices;
      } else {
        selectedChoice = widget.initialChoices.first;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.horizScroll) {
      return Container(
        alignment: Alignment.centerLeft,
        height: 55,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: _buildChoiceList(),
        ),
      );
    } else {
      return Wrap(
        alignment: WrapAlignment.center,
        children: _buildChoiceList(),
      );
    }
  }
}
