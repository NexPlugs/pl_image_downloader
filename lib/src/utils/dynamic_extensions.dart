/// Dynamic Extensions
/// This extension is used to convert the dynamic value to the int or string value.
class DynamicParser {
  static int? parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Get the string value of the dynamic value.
  /// @return The string value of the dynamic value.
  /// @throws Exception if the dynamic value is not a string.
  static String? parseString(dynamic value) {
    if (value is String) return value;
    return value.toString();
  }

  /// Get the dynamic value of the dynamic value.
  /// @return The dynamic value of the dynamic value.
  /// @throws Exception if the dynamic value is not a dynamic.
  static dynamic parseDynamic(dynamic value) {
    return value;
  }

  /// Get the bool value of the dynamic value.
  /// @return The bool value of the dynamic value.
  /// @throws Exception if the dynamic value is not a bool.
  static bool? parseBool(dynamic value) {
    if (value is bool) return value;
    return null;
  }

  /// Get the double value of the dynamic value.
  /// @return The double value of the dynamic value.
  /// @throws Exception if the dynamic value is not a double.
  static double? parseDouble(dynamic value) {
    if (value is double) return value;
    return null;
  }
}
