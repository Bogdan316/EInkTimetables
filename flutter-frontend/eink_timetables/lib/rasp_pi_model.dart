import 'package:eink_timetables/rasp_pi_image_model.dart';

class RaspPi {
  final String id;
  final String name;
  final List<RaspPiImage> timetableUrls;
  bool isClear;
  String displaying;

  RaspPi({
    required this.id,
    required this.name,
    required this.timetableUrls,
    required this.isClear,
    required this.displaying,
  });

  factory RaspPi.fromJson(Map<String, dynamic> json) {
    var id = json['id'];
    var isClear = json['details']['is_clear'];
    var name = json['details']['name'];

    var details = Map.from(json['details']);

    var displaying = '';
    if (details.containsKey('displaying')) {
      displaying = details['displaying'] as String;
    }

    var urls = <RaspPiImage>[];
    if (details.containsKey('images')) {
      urls = Map.from(details['images'])
          .entries
          .map((e) => RaspPiImage.fromJson(e.value))
          .toList();
    }

    return RaspPi(
        id: id, name: name, timetableUrls: urls, isClear: isClear, displaying: displaying);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RaspPi && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RaspPi{id: $id, timetableUrls: $timetableUrls, isClear: $isClear, displaying: $displaying}';
  }
}
