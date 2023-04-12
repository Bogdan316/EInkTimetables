import 'package:flutter/material.dart';

PopupMenuButton buildPopUpMenu(void Function(String) callback) {
  return PopupMenuButton(
    onSelected: (value) => callback(value),
    position: PopupMenuPosition.under,
    offset: const Offset(0, 5),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(8.0),
        bottomRight: Radius.circular(8.0),
        topLeft: Radius.circular(8.0),
        topRight: Radius.circular(8.0),
      ),
    ),
    padding: const EdgeInsets.all(0),
    splashRadius: 20,
    icon: const Icon(Icons.settings),
    itemBuilder: (context) => [
      buildPopupMenuItem('clear', 'Clear', Icons.clear_outlined),
      buildPopupMenuItem('delete', 'Delete', Icons.delete_outline),
    ],
  );
}

PopupMenuItem buildPopupMenuItem(String value, String text, IconData iconData) {
  return PopupMenuItem(
    value: value,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon(
          iconData,
          color: Colors.black,
        ),
        Text(text),
      ],
    ),
  );
}
