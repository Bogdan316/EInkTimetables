import 'package:flutter/material.dart';

class RaspPiPopupMenu extends StatefulWidget {
  final void Function(String) callback;

  const RaspPiPopupMenu({required this.callback, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RaspPiPopupMenuState();
}

class _RaspPiPopupMenuState extends State<RaspPiPopupMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) => widget.callback(value),
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
        _buildPopupMenuItem('upload', 'Upload', Icons.upload),
        _buildPopupMenuItem('clear', 'Clear', Icons.clear_outlined),
        _buildPopupMenuItem('delete', 'Delete', Icons.delete_outline),
      ],
    );
  }

  PopupMenuItem _buildPopupMenuItem(String value, String text, IconData iconData) {
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
}

