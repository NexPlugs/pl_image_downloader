/// Download Mode
/// This enum is used to define the download mode.
enum DownloadMode {
  /// Normal download mode.
  normal(name: "normal"),

  /// Running background service download mode. This mode only workds on android
  runningBackgroundService(name: "runningBackgroundService");

  final String name;

  const DownloadMode({required this.name});

  /// Get the download mode from the name.
  static DownloadMode fromName(String name) {
    return DownloadMode.values.firstWhere(
      (e) => e.name.toLowerCase().trim() == name.toLowerCase().trim(),
      orElse: () => throw Exception('Download mode not found: $name'),
    );
  }
}
