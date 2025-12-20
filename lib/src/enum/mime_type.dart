/// Mime Type
/// This enum is used to define the mime type for the download service.
enum MimeType {
  /// Image/jpeg
  imageJpeg(name: "image/jpeg"),

  /// Image/png
  imagePng(name: "image/png"),

  /// Image/gif
  imageGif(name: "image/gif"),

  /// Image/svg+xml
  imageSvgXml(name: "image/svg+xml"),

  /// Image/bmp
  imageBmp(name: "image/bmp");

  final String name;

  const MimeType({required this.name});

  /// Get the mime type from the name.
  static MimeType fromName(String name) {
    return MimeType.values.firstWhere(
      (e) => e.name.toLowerCase().trim() == name.toLowerCase().trim(),
      orElse: () => throw Exception('Mime type not found: $name'),
    );
  }
}
