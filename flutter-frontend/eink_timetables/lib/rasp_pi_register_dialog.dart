import 'package:eink_timetables/rasp_pi_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masked_text/masked_text.dart';

class RaspPiRegisterDialog extends StatefulWidget {
  final _raspPiService = const RaspPiService();

  const RaspPiRegisterDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RaspPiRegisterDialogState();
}

class _RaspPiRegisterDialogState extends State<RaspPiRegisterDialog> {
  final textController = TextEditingController();
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
        AlertDialog(
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
                        setState(() {
                          _isLoading = true;
                        });
                        await widget._raspPiService
                            .registerRaspPi(textController.text)
                            .then((raspPi) {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop(raspPi);
                        });
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
        ),
        Align(
          alignment: FractionalOffset.center,
          child: loadingIndicator,
        ),
      ],
    );
  }
}
