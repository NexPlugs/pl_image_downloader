/// Download Directory
/// This enum is used to store the download directory.
enum DownloadDirectory {
  music(directoryName: "music"),
  pictures(directoryName: "pictures"),
  podcasts(directoryName: "podcasts"),
  movies(directoryName: "movies"),
  downloads(directoryName: "downloads");

  final String directoryName;

  const DownloadDirectory({required this.directoryName});

  /// Get the download directory from the string
  static DownloadDirectory fromString(String directoryName) {
    return DownloadDirectory.values.firstWhere(
      (e) => e.directoryName == directoryName,
      orElse: () =>
          throw Exception('Download directory not found: $directoryName'),
    );
  }
}
