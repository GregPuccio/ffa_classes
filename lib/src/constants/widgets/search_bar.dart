import 'package:flutter/material.dart';

PreferredSizeWidget searchBar(TextEditingController controller, Color cardColor,
    {String text = 'Search by last name'}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kTextTabBarHeight),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.search),
          const SizedBox(width: 5),
          Expanded(
            child: TextField(
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              scrollPadding: const EdgeInsets.all(8),
              decoration: InputDecoration.collapsed(
                hintText: text,
                hintStyle: TextStyle(color: Colors.grey.shade700),
              ),
              controller: controller,
            ),
          ),
        ],
      ),
    ),
  );
}
