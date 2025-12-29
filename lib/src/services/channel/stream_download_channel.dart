import 'package:flutter/services.dart';
import 'package:pl_image_downloader/src/utils/logger.dart';

import '../../models/download_event_bridge.dart';
import '../../utils/channel_tag.dart';

class StreamDownloadChannel {
  static const String _tag = 'eventBridge';

  ///Singleton
  static final StreamDownloadChannel _instance =
      StreamDownloadChannel._internal();

  ///Constructor
  StreamDownloadChannel._internal();

  ///Singleton
  static StreamDownloadChannel get instance => _instance;

  // Service Channel
  final MethodChannel _serviceChannel = MethodChannel(
    ChannelTag.serviceChannel,
  );

  Function(DownloadEventBridge)? _callBack;

  /// Set Call Back
  factory StreamDownloadChannel.setCallBack(
    Function(DownloadEventBridge) callBack,
  ) {
    instance._callBack = callBack;
    return instance;
  }

  /// Listen Event Bridge
  /// This method is used to listen to the event bridge.
  /// @return A future that completes when the event bridge is listened to.
  /// @throws Exception if the event bridge fails to listen to.
  void listenEventBridge() {
    try {
      _serviceChannel.setMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method != ChannelTag.eventBridge) return;

        if (methodCall.arguments is! Map) return;
        final json = Map<String, dynamic>.from(methodCall.arguments);

        final eventBridge = DownloadEventBridge.fromValue(json);

        _callBack?.call(eventBridge);
      });
    } catch (e) {
      Logger.e(_tag, e.toString());
    }
  }

  /// Dispose
  /// This method is used to dispose the stream download channel.
  /// @throws Exception if the stream download channel fails to dispose.
  void dispose() {
    try {
      _serviceChannel.setMethodCallHandler(null);
      _callBack = null;
    } catch (e) {
      Logger.e(_tag, "[Dispose StreamDownloadChannel] Error: $e");
    }
  }
}
