import 'package:eink_timetables/rasp_pi_model.dart';
import 'package:eink_timetables/rasp_pi_service.dart';
import 'package:flutter/material.dart';

class RaspPiScreen extends StatefulWidget {
  final RaspPi raspPi;

  const RaspPiScreen({super.key, required this.raspPi});

  @override
  State<RaspPiScreen> createState() => _RaspPiScreenState();
}

class _RaspPiScreenState extends State<RaspPiScreen> {
  final RaspPiService raspPiService = const RaspPiService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _isLoading
        ? Container(
            color: Colors.grey[300]!.withOpacity(0.5),
            child: const Padding(
              padding: EdgeInsets.all(5.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Container();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(widget.raspPi.name),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ListView(
                  semanticChildCount: widget.raspPi.timetableUrls.length,
                  scrollDirection: Axis.vertical,
                  children: [
                    for (var img in widget.raspPi.timetableUrls)
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          color: img.blobName == widget.raspPi.displaying
                              ? Theme.of(context).primaryColorLight
                              : Theme.of(context).cardColor,
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shadowColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 20,
                          margin: const EdgeInsets.all(10),
                          child: InkWell(
                            splashColor: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0),
                            onTap: () async {
                              if (img.blobName != widget.raspPi.displaying) {
                                setState(() {
                                  _isLoading = true;
                                });

                                await raspPiService.uploadPastTimetable(
                                    widget.raspPi, img.blobName);

                                setState(() {
                                  widget.raspPi.displaying = img.blobName;
                                  _isLoading = false;
                                });
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Image.network(
                                    img.url,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 10.0, 0, 10.0),
                                  child: Text(
                                    img.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 0, 0, 20.0),
                                  child: Text(
                                    img.uploadDate,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: FractionalOffset.center,
          child: loadingIndicator,
        ),
      ],
    );
  }
}
