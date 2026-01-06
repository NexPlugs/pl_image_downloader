/// Extension for nullable types.
/// This extension is used to call a function on a nullable type.
/// @param function The function to call.
/// @return The result of the function call.
extension FunctionExtension<T> on T? {
  void let(Function(T) function) {
    if (this == null) {
      return;
    }
    function(this as T);
  }
}
