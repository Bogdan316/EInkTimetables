import 'package:eink_timetables/rasp_pi_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masked_text/masked_text.dart';

import 'error_dialog.dart';
import 'exceptions.dart';

class RaspPiRegisterDialog extends StatefulWidget {
  final _raspPiService = const RaspPiService();

  const RaspPiRegisterDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RaspPiRegisterDialogState();
}

class _RaspPiRegisterDialogState extends State<RaspPiRegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  final macTextController = TextEditingController();
  final nameTextController = TextEditingController();

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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is mandatory.';
                          }
                          return null;
                        },
                        autofocus: true,
                        autocorrect: false,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        maxLength: 20,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter Name',
                          labelText: 'Name',
                        ),
                        controller: nameTextController,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp("[0-9a-zA-Z]")),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: MaskedTextField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is mandatory.';
                          }
                          return null;
                        },
                        mask: 'xx:xx:xx:xx:xx:xx',
                        maskFilter: {'x': RegExp(r'\d|[a-fA-F]')},
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        maxLength: 17,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter MAC Address',
                          labelText: 'MAC',
                        ),
                        controller: macTextController,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              await widget._raspPiService
                                  .registerRaspPi(
                                    macTextController.text,
                                    nameTextController.text,
                                  )
                                  .then((_) => Navigator.of(context).pop())
                                  .whenComplete(
                                    () => setState(() => _isLoading = false),
                                  );
                            } on RaspPiAlreadyRegisteredException catch (e) {
                              showErrorDialog(
                                'Raspberry Pi Already Registered',
                                e.msg,
                                context,
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
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
        ),
        Align(
          alignment: FractionalOffset.center,
          child: loadingIndicator,
        ),
      ],
    );
  }
}
