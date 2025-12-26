/// Download Result
class DownloadResult {
  /// This class is used to store the download result.
  final String path;

  /// The path of the downloaded file.
  final String fileName;

  /// The directory result of the downloaded file.
  final String directoryResult;

  DownloadResult({
    required this.path,
    required this.fileName,
    required this.directoryResult,
  });

  /// Create a download result from a json.
  factory DownloadResult.fromJson(Map<String, dynamic> json) {
    return DownloadResult(
      path: json['path'],
      fileName: json['fileName'],
      directoryResult: json['directoryResult'],
    );
  }
}
