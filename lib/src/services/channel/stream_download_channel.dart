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
        Logger.i(
          _tag,
          "[ListenEventBridge] Method call: ${methodCall.method} Arguments: ${methodCall.arguments} type: ${methodCall.arguments.runtimeType}",
        );
        if (methodCall.arguments is! Map) return;
        final json = Map<String, dynamic>.from(methodCall.arguments);
        Logger.i(_tag, "[ListenEventBridge] Json: $json");

        final eventBridge = DownloadEventBridge.fromValue(json);

        Logger.i(_tag, "[ListenEventBridge] Event bridge: $eventBridge");
        _callBack?.call(eventBridge);
      });
    } catch (e) {
      Logger.e(_tag, e.toString());
    }
  }
}
