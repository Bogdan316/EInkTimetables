import 'package:eink_timetables/rasp_pi_service.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class RaspPiScanDialog extends StatefulWidget {
  final _raspPiService = const RaspPiService();

  const RaspPiScanDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RaspPiScanDialogState();
}

class _RaspPiScanDialogState extends State<RaspPiScanDialog> {
  late Future<List<String>> raspPiIds;

  @override
  void initState() {
    super.initState();
    raspPiIds = widget._raspPiService.scan();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: raspPiIds,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            return MultiSelectDialog(
              height: 200,
              width: 200,
              selectedColor: Theme.of(context).primaryColor,
              title: const Text(
                'Scanned Raspberry Pis',
                style: TextStyle(fontSize: 24.0),
              ),
              items: snapshot.data!.map((e) => MultiSelectItem(e, e)).toList(),
              initialValue: const [],
              onConfirm: (values) {
                if (values.isNotEmpty) {
                  widget._raspPiService
                      .registerMultipleRaspPis(
                          values.map((e) => e as String).toList());
                }
              },
            );
          } else {
            return AlertDialog(
              title: const Text('Scanned Raspberry Pis'),
              content:
                  const Text('No Raspberry Pis were found on the network.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          }
        } else {
          return const Padding(
            padding: EdgeInsets.all(10.0),
            child: SizedBox(
              height: 50,
              width: 50,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}
