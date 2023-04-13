class RaspPiImage {
  final String name;
  final String url;
  final String uploadDate;

  const RaspPiImage({
    required this.name,
    required this.url,
    required this.uploadDate,
  });

  factory RaspPiImage.fromJson(Map<String, dynamic> json) {
    return RaspPiImage(
      name: json['blob_name'] as String,
      url: json['url'] as String,
      uploadDate: json['upload_date'] as String,
    );
  }
}
