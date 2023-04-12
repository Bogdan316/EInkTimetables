import 'dart:convert';

import 'package:eink_timetables/rasp_model.dart';
import 'package:http/http.dart' as http;

class RaspPiService{
  Future<RaspPi> registerRaspPi(String raspMac) async {
    final response = await http
        .post(Uri.parse('http://127.0.0.1:8000/register/mac/$raspMac'));

    if(response.statusCode != 200) {
      throw Exception('Failed to register Raspberry Pi '
          'with the provided MAC ($raspMac).');
    }

    return RaspPi.fromJson(jsonDecode(response.body));
  }

  Future<void> clearRaspPi(RaspPi pi) async {
    final response = await http
        .post(Uri.parse('http://127.0.0.1:8000/pi/${pi.id}/clear-screen/'));

    if(response.statusCode != 200) {
      throw Exception('Failed to clear Raspberry Pi '
          'with the provided ID (${pi.id}).');
    }
  }

}
