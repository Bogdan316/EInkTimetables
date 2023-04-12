import 'package:eink_timetables/rasp_model.dart';
import 'package:eink_timetables/rasp_pi_list_tile_menu.dart';
import 'package:flutter/material.dart';

import 'rasp_pi_icon.dart';

Material buildRaspPiTile(RaspPi pi, Function()? onTap, void Function(String) callback) {
  return Material(
    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
    shadowColor: Colors.blueGrey,
    elevation: 20.0,
    child: Container(
      color: Colors.white10,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(10),
        dense: true,
        leading: const Icon(
          RaspPiIcon.raspberry_pi,
          size: 40,
          color: Colors.black,
        ),
        title: Text(
          pi.id,
          style: const TextStyle(fontSize: 20),
        ),
        subtitle: Text(pi.id),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'The screen is currently '
                  '${pi.isClear ? 'cleared' : 'not cleared'}.',
              child: Icon(
                Icons.screenshot_monitor_rounded,
                color: pi.isClear ? Colors.green : Colors.black,
              ),
            ),
            const SizedBox(width: 50),
            buildPopUpMenu(callback),
          ],
        ),
      ),
    ),
  );
}
