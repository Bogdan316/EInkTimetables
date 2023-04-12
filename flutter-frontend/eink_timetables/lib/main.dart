import 'dart:collection';

import 'package:eink_timetables/rasp_model.dart';
import 'package:eink_timetables/rasp_pi_list_tile.dart';
import 'package:eink_timetables/rasp_pi_screen.dart';
import 'package:eink_timetables/rasp_pi_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masked_text/masked_text.dart';

import 'colors.dart';
import 'rasp_pi_icon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetables Management',
      theme: ThemeData(
        primarySwatch: createMaterialColor(
          const Color(0xFF01135d),
        ),
      ),
      home: MyHomePage(title: 'Timetables Management'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  final raspPiService = RaspPiService();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final HashSet<RaspPi> _raspPis = HashSet();

  void _registerRaspPi() async {
    var raspPi = await showDataAlert(widget.raspPiService);

    if (raspPi != null) {
      setState(() {
        _raspPis.add(raspPi);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: _raspPis.map((pi) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: buildRaspPiTile(
                pi,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RaspPiScreen(
                      raspPi: pi,
                    ),
                  ),
                ),
                (value) {
                  switch (value) {
                    case 'clear':
                      {
                        widget.raspPiService.clearRaspPi(pi);
                        break;
                      }
                    case 'delete':
                      {
                        setState(() {
                          _raspPis.remove(pi);
                        });
                        break;
                      }
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _registerRaspPi,
        tooltip: 'Register',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> showDataAlert(RaspPiService raspPiService) {
    final textController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.only(
            top: 10.0,
          ),
          title: const Text(
            'Register Raspberry Pi',
            style: TextStyle(fontSize: 24.0),
          ),
          content: Container(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: MaskedTextField(
                      autofocus: true,
                      mask: 'xx:xx:xx:xx:xx:xx',
                      maskFilter: {'x': RegExp(r'\d|[a-fA-F]')},
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      maxLength: 17,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter MAC Address',
                        labelText: 'MAC',
                      ),
                      controller: textController,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        await raspPiService
                            .registerRaspPi(textController.text)
                            .then(
                                (raspPi) => Navigator.of(context).pop(raspPi));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text(
                        "Register",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
