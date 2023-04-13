import 'dart:typed_data';

import 'package:eink_timetables/rasp_pi_model.dart';
import 'package:eink_timetables/rasp_pi_list_tile_menu.dart';
import 'package:eink_timetables/rasp_pi_register_dialog.dart';
import 'package:eink_timetables/rasp_pi_screen.dart';
import 'package:eink_timetables/rasp_pi_service.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';

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
      home: const MyHomePage(title: 'Timetables Management'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  final raspPiService = const RaspPiService();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<RaspPi>> _raspPis;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadRegisteredPis();
  }

  void _loadRegisteredPis() {
    _raspPis = widget.raspPiService.getRaspPis();
  }

  void _registerRaspPi() async {
    await _showDataAlert(widget.raspPiService);
    setState(() {
      _loadRegisteredPis();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: FutureBuilder<List<RaspPi>>(
              future: _raspPis,
              builder: (context, snapshot) {
                var raspList = <RaspPi>[];
                if (snapshot.hasData) {
                  raspList = snapshot.data!;
                }
                return ListView(
                  children: raspList.map(
                    (pi) {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Material(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                          shadowColor: Colors.blueGrey,
                          elevation: 20.0,
                          child: Container(
                            color: Colors.white10,
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RaspPiScreen(
                                    raspPi: pi,
                                  ),
                                ),
                              ).then((_) => setState(() {
                                    _loadRegisteredPis();
                                  })),
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
                                      color: pi.isClear
                                          ? Colors.green
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 50),
                                  RaspPiPopupMenu(
                                    callback: (value) async {
                                      switch (value) {
                                        case 'clear':
                                          {
                                            widget.raspPiService
                                                .clearRaspPi(pi)
                                                .then((_) => setState(() {
                                                      _loadRegisteredPis();
                                                    }));
                                            break;
                                          }
                                        case 'delete':
                                          {
                                            setState(
                                              () {
                                                raspList.remove(pi);
                                              },
                                            );
                                            break;
                                          }
                                        case 'upload':
                                          {
                                            var timetable = await FilePickerWeb
                                                .platform
                                                .pickFiles();
                                            if (timetable != null) {
                                              widget.raspPiService
                                                  .uploadTimetable(
                                                pi,
                                                timetable.files.single.bytes!,
                                                timetable.files.single.name,
                                              );
                                              setState(() {});
                                            }
                                            break;
                                          }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _registerRaspPi,
        tooltip: 'Register',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> _showDataAlert(RaspPiService raspPiService) {
    return showDialog(
      context: context,
      builder: (context) {
        return const RaspPiRegisterDialog();
      },
    );
  }
}
