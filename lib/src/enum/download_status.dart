/// Download Status
/// This enum is used to define the status of the download task.
enum DownloadStatus {
  idle(name: "idle"),

  /// The download task is pending.
  pending(name: "pending"),

  /// The download task is downloading.
  downloading(name: "downloading"),

  /// The download task is completed.
  completed(name: "completed"),

  /// The download task is failed.
  failed(name: "failed"),

  /// The download task is canceled.
  canceled(name: "canceled"),

  paused(name: "paused");

  final String name;

  const DownloadStatus({required this.name});

  /// Get the download status from the name.
  static DownloadStatus fromName(String name) {
    return DownloadStatus.values.firstWhere(
      (e) => e.name.toLowerCase().trim() == name.toLowerCase().trim(),
      orElse: () => throw Exception('Download status not found: $name'),
    );
  }

  /// Get if the task should be cleared after completion.
  bool get clearTaskAfterCompletion =>
      this == completed || this == failed || this == canceled;
}
