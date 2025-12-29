import 'dart:async';

/// AsyncMutex
/// This class is used to create a mutex for asynchronous operations.
class AsyncMutex {
  Future _running = Future.value();

  /// Enqueued
  int _enqueued = 0;

  /// Enqueued
  int get enqueued => _enqueued;

  /// Run
  /// This method is used to run a function asynchronously.
  Future<T> run<T>(Future<T> Function() fn) async {
    final completer = Completer<T>();

    _enqueued++;
    _running.whenComplete(() {
      _enqueued--;
      completer.complete(Future<T>.sync(fn));
    });

    return _running = completer.future;
  }
}
