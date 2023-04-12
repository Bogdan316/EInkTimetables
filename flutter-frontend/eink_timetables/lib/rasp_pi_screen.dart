import 'package:eink_timetables/rasp_model.dart';
import 'package:flutter/material.dart';

class RaspPiScreen extends StatelessWidget {
  final RaspPi raspPi;
  const RaspPiScreen({super.key, required this.raspPi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(raspPi.id),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              for (var url in raspPi.timetableUrls)
                SizedBox(
                  height: 400,
                  width: 300,
                  child: Image.network(url),
                )
            ],
          ),
        ));
  }
}
