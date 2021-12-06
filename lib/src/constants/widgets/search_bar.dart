import 'package:flutter/material.dart';

PreferredSizeWidget searchBar(TextEditingController controller, Color cardColor,
    {String text = 'Search by first name'}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(65),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
      child: TextField(
        decoration: InputDecoration(
          fillColor: cardColor,
          filled: true,
          hintText: text,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.search),
        ),
        controller: controller,
      ),
    ),
  );
}
