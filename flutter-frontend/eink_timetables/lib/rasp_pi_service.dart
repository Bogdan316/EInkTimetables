import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:eink_timetables/exceptions.dart';
import 'package:eink_timetables/rasp_pi_model.dart';

import 'package:http/http.dart' as http;

class RaspPiService {
  const RaspPiService();

  Future<List<String>> scan() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/scan-pis/'));

    if (response.statusCode != 200) {
      throw UnfulfilledRequestException(
          'Not able to retrieve registered Raspberry Pis.');
    }
    var pis = <String>[];
    for (var pi in jsonDecode(response.body)['unregistered_pis']) {
      pis.add(pi);
    }

    return pis;
  }

  Future<void> registerMultipleRaspPis(List<String> ids) async {
    var dio = Dio();
    var response = await dio.post(
        'http://127.0.0.1:8000/register/multiple-ids/',
        data: {'ids': ids});

    if (response.statusCode != 200) {
      throw UnfulfilledRequestException(
          "Not able to register IDs: ${ids.toString()}.");
    }
  }

  Future<void> registerRaspPi(String raspMac, String raspName) async {
    final response = await http.post(Uri.parse(
        'http://127.0.0.1:8000/register/mac/$raspMac/?name=$raspName'));

    if (response.statusCode == 409) {
      throw RaspPiAlreadyRegisteredException(
          'The Raspberry Pi with the MAC address: $raspMac is already registered.');
    }

    if (response.statusCode != 200) {
      throw UnfulfilledRequestException('Failed to register Raspberry Pi '
          'with MAC address: $raspMac.');
    }
  }

  Future<List<RaspPi>> getRegisteredRaspPis() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/registered-pis/'));

    if (response.statusCode != 200) {
      throw UnfulfilledRequestException(
          'Not able to retrieve registered Raspberry Pis.');
    }

    List<RaspPi> pis = [];
    for (var raspJson in jsonDecode(response.body)) {
      pis.add(RaspPi.fromJson(raspJson));
    }

    return pis;
  }

  Future<void> renameRaspPi(RaspPi raspPi, String newName) async {
    final response = await http.post(Uri.parse(
        'http://127.0.0.1:8000/rename/id/${raspPi.id}/?name=$newName'));

    if (response.statusCode != 200) {
      throw UnfulfilledRequestException('Failed to rename Raspberry Pi '
          'with ID: ${raspPi.id}.');
    }
  }

  Future<void> clearRaspPi(RaspPi raspPi) async {
    final response = await http
        .post(Uri.parse('http://127.0.0.1:8000/pi/${raspPi.id}/clear-screen/'));

    if (response.statusCode != 200) {
      throw UnfulfilledRequestException('Failed to clear Raspberry Pi '
          'with ID: ${raspPi.id}.');
    }
  }

  Future<void> uploadPastTimetable(RaspPi raspName, String blobName) async {
    final response = await http.post(Uri.parse(
        'http://127.0.0.1:8000/pi/${raspName.id}/upload-past-timetable/?blob_name=$blobName'));

    if (response.statusCode != 200) {
      throw UnfulfilledRequestException(
          "Not able to upload timetable for Raspberry Pi with ID: ${raspName.id}.");
    }
  }

  Future<void> uploadTimetable(
      RaspPi raspPi, Uint8List img, String imgName) async {
    var formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(img, filename: imgName),
    });

    var dio = Dio();
    var response = await dio.post(
        'http://127.0.0.1:8000/pi/${raspPi.id}/upload-timetable/',
        data: formData);

    if (response.statusCode != 200) {
      throw UnfulfilledRequestException(
          "Not able to upload timetable for Raspberry Pi with ID: ${raspPi.id}.");
    }
  }

  Future<void> unregisterRaspPi(RaspPi raspPi) async {
    final response = await http
        .post(Uri.parse('http://127.0.0.1:8000/unregister/id/${raspPi.id}'));

    if (response.statusCode != 200) {
      throw UnfulfilledRequestException('Failed to unregister Raspberry Pi '
          'with ID: ${raspPi.id}.');
    }
  }
}
