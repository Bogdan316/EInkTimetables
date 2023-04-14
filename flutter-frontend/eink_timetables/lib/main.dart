import 'package:eink_timetables/rasp_pi_model.dart';
import 'package:eink_timetables/rasp_pi_list_tile_menu.dart';
import 'package:eink_timetables/rasp_pi_register_dialog.dart';
import 'package:eink_timetables/rasp_pi_scan_dialog.dart';
import 'package:eink_timetables/rasp_pi_screen.dart';
import 'package:eink_timetables/rasp_pi_service.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  void initState() {
    super.initState();
    _loadRegisteredPis();
  }

  void _loadRegisteredPis() {
    _raspPis = widget.raspPiService.getRegisteredRaspPis();
  }

  void _registerRaspPi() async {
    await _showDataAlert();
    setState(_loadRegisteredPis);
  }

  void _registerMultipleRaspPis() async {
    await showDialog(
      context: context,
      builder: (context) {
        return const RaspPiScanDialog();
      },
    );
    await Future.delayed(const Duration(seconds: 2));
    setState(_loadRegisteredPis);
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
              if (snapshot.hasData) {
                var raspList = snapshot.data!;

                return Column(
                  children: [
                    ...raspList.map(
                      (pi) {
                        var controller = TextEditingController(text: pi.name);
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
                                ).then((_) => setState(_loadRegisteredPis)),
                                contentPadding: const EdgeInsets.all(10),
                                dense: true,
                                leading: const Icon(
                                  RaspPiIcon.raspberry_pi,
                                  size: 40,
                                  color: Colors.black,
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 10.0,
                                    top: 8.0,
                                  ),
                                  child: TextFormField(
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.enforced,
                                    maxLength: 20,
                                    controller: controller,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      isCollapsed: true,
                                      border: InputBorder.none,
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 20),
                                    onEditingComplete: () => widget
                                        .raspPiService
                                        .renameRaspPi(pi, controller.text)
                                        .then((_) =>
                                            FocusScope.of(context).unfocus())
                                        .whenComplete(
                                            () => setState(_loadRegisteredPis)),
                                  ),
                                ),
                                subtitle: Text(
                                  'ID: ${pi.id}',
                                  style: const TextStyle(fontSize: 15),
                                ),
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
                                                  .then((_) => setState(
                                                      _loadRegisteredPis));
                                              break;
                                            }
                                          case 'delete':
                                            {
                                              widget.raspPiService
                                                  .unregisterRaspPi(pi)
                                                  .then((_) => setState(
                                                      _loadRegisteredPis));
                                              break;
                                            }
                                          case 'upload':
                                            {
                                              var timetable =
                                                  await FilePickerWeb.platform
                                                      .pickFiles(
                                                type: FileType.custom,
                                                allowedExtensions: [
                                                  'jpeg',
                                                  'jpg',
                                                  'png'
                                                ],
                                              );
                                              if (timetable != null) {
                                                await widget.raspPiService
                                                    .uploadTimetable(
                                                      pi,
                                                      timetable
                                                          .files.single.bytes!,
                                                      timetable
                                                          .files.single.name,
                                                    )
                                                    .then((_) => setState(
                                                        _loadRegisteredPis));
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
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 50,
                        width: 100,
                        child: ElevatedButton(
                          onPressed: _registerMultipleRaspPis,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: const Text("Scan"),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox(
                  height: 50,
                  width: 50,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _registerRaspPi,
        tooltip: 'Register',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> _showDataAlert() {
    return showDialog(
      context: context,
      builder: (context) {
        return const RaspPiRegisterDialog();
      },
    );
  }
}
