import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:eink_timetables/rasp_pi_model.dart';

import 'package:http/http.dart' as http;

class RaspPiService {
  const RaspPiService();

  Future<RaspPi> registerRaspPi(String raspMac) async {
    final response = await http
        .post(Uri.parse('http://127.0.0.1:8000/register/mac/$raspMac'));

    if (response.statusCode != 200) {
      throw Exception('Failed to register Raspberry Pi '
          'with the provided MAC ($raspMac).');
    }

    return RaspPi.fromJson(jsonDecode(response.body));
  }

  Future<void> clearRaspPi(RaspPi pi) async {
    final response = await http
        .post(Uri.parse('http://127.0.0.1:8000/pi/${pi.id}/clear-screen/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to clear Raspberry Pi '
          'with the provided ID (${pi.id}).');
    }
  }

  Future<void> uploadPastTimetable(RaspPi pi, String imgName) async {
    final response = await http.post(Uri.parse(
        'http://127.0.0.1:8000/pi/${pi.id}/upload-past-timetable/?image_name=$imgName'));

    if (response.statusCode != 200) {
      throw Exception('Big news');
    }
  }

  Future<List<RaspPi>> getRaspPis() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/registered-pis/'));

    if (response.statusCode != 200) {
      throw Exception('Big news');
    }

    List<RaspPi> pis = [];
    for (var raspJson in jsonDecode(response.body)) {
      pis.add(RaspPi.fromJson(raspJson));
    }

    return pis;
  }

  Future<void> uploadTimetable(RaspPi raspPi, Uint8List img, String imgName) async {
    var formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(img, filename: imgName),
    });

    var dio = Dio();
    var resp = await dio.post('http://127.0.0.1:8000/pi/${raspPi.id}/upload-timetable/', data: formData);
    print(resp.data);
  }
}
