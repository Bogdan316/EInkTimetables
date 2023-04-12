import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TooltipSample extends StatelessWidget {
  final String message;
  const TooltipSample({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient:
        const LinearGradient(colors: <Color>[Colors.amber, Colors.red]),
      ),
      height: 50,
      padding: const EdgeInsets.all(8.0),
      preferBelow: false,
      textStyle: const TextStyle(
        fontSize: 24,
      ),
      showDuration: const Duration(seconds: 2),
      waitDuration: const Duration(seconds: 1),
      child: const Text('Tap this text and hold down to show a tooltip.'),
    );
  }
}