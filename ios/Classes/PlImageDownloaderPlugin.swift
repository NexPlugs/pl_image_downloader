import Flutter
import UIKit
import Photos

public class PlImageDownloaderPlugin: NSObject, FlutterPlugin {

    private var service: DownloadHandler?
    private var messenger: FlutterBinaryMessenger?

    private static var shared: PlImageDownloaderPlugin?

    public static func register(with registrar: FlutterPluginRegistrar) {

        NSLog("REGISTER PLUGIN")

        let channel = FlutterMethodChannel(
            name: ChannelTag.serviceChannel,
            binaryMessenger: registrar.messenger()
        )

        let instance = PlImageDownloaderPlugin()
        shared = instance

        instance.messenger = registrar.messenger()

        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {

        NSLog("Method called: \(call.method)")

        if service == nil,
           let messenger = messenger {
            service = DownloadHandler(messenger: messenger)
        }

        service?.doAction(
            method: call.method,
            arguments: call.arguments as? [String: Any],
            result: result
        ) { error in
            print("DownloadHandler error: \(error)")
        }
    }
}