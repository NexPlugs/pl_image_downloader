/// Notification Config
class NotificationConfig {
  /// The title of the notification.
  final String title;

  /// The body of the notification.
  final String body;

  /// Whether to display the progress in the notification.
  final bool displayProgress;

  /// Create a new notification config.
  NotificationConfig({
    required this.title,
    required this.body,
    required this.displayProgress,
  });

  /// Convert the notification config to a JSON object.
  Map<String, dynamic> toJson() {
    return {'title': title, 'body': body, 'displayProgress': displayProgress};
  }
}
