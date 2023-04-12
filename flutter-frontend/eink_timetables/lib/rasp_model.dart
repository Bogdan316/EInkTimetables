class RaspPi{
  final String id;
  final List<String> timetableUrls;
  final bool isClear;

  const RaspPi({
    required this.id,
    required this.timetableUrls,
    required this.isClear,
  });

  factory RaspPi.fromJson(Map<String, dynamic> json){
    var id = json['id'];
    var isClear = json['details']['is_clear'];
    var urls = Map.from(json['details']['images']).entries.map(
            (e) => e.value['url'] as String
    ).toList();

    return RaspPi(id: id, timetableUrls: urls, isClear: isClear);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RaspPi &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RaspPi{id: $id, timetableUrls: $timetableUrls, isClear: $isClear}';
  }
}