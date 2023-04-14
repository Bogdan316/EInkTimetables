class RaspPiImage {
  final String name;
  final String blobName;
  final String url;
  final String uploadDate;

  const RaspPiImage({
    required this.name,
    required this.blobName,
    required this.url,
    required this.uploadDate,
  });

  factory RaspPiImage.fromJson(Map<String, dynamic> json) {
    return RaspPiImage(
      blobName: json['blob_name'] as String,
      name: json['img_name'] as String,
      url: json['url'] as String,
      uploadDate: json['upload_date'] as String,
    );
  }
}
