enum CallBack {
  // Position CallBack
  progress(method: "progress"),
  // Negative CallBack
  negative(method: "negative"),
  // Neutral CallBack
  neutral(method: "neutral"),

  // Result CallBack
  result(method: "result");

  final String method;
  const CallBack({required this.method});

  /// Get the method name
  String get methodName => method;

  /// Get the call back from the method name
  static CallBack fromMethodName(String methodName) {
    return CallBack.values.firstWhere(
      (e) => e.methodName == methodName,
      orElse: () => throw Exception('CallBack not found: $methodName'),
    );
  }
}
