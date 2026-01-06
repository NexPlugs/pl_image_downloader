import '../utils/dynamic_extensions.dart';

/// Download Result
class DownloadResult {
  /// This class is used to store the download result.
  final String path;

  /// The path of the downloaded file.
  final String? fileName;

  /// The directory result of the downloaded file.
  final String? directoryResult;

  /// The success status of the download.
  final bool isSuccess;

  /// The error message of the download.
  final String? errorMessage;

  DownloadResult({
    required this.path,
    this.fileName,
    this.directoryResult,
    this.isSuccess = false,
    this.errorMessage,
  });

  /// Create a download result from a json.
  factory DownloadResult.fromJson(Map<String, dynamic> json) {
    return DownloadResult(
      path: json['path'],
      fileName: json['fileName'] ?? '',
      directoryResult: json['directoryResult'] ?? '',
      isSuccess: DynamicParser.parseBool(json['isSuccess']) ?? false,
      errorMessage: json['errorMessage'] ?? '',
    );
  }
}
