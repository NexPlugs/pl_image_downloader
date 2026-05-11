//
//  DownloadBridge.swift
//
//  Created by Nguyễn Minh Hưng on 8/5/26.
//



struct DownloadBridge {
    static private let TAG = "DownloadBridge"

    private  var batteryChannel: FlutterMethodChannel?
    
    public init(messenger: FlutterBinaryMessenger) {
        batteryChannel = FlutterMethodChannel(name: ChannelTag.serviceChannel, binaryMessenger: messenger)
    }
    
    func invokeProgress(progress: Int, id: Int64) {
        print("\(DownloadBridge.TAG) invokeProgress: \(progress) id: \(id)")
        
        let callBack = DownloadCallBack.onProgress(value: progress, id: id)
        
        DispatchQueue.main.async {
            self.batteryChannel?.invokeMethod(ChannelTag.eventBridge, arguments: callBack.toMap())
        }
    }
    
    func invokeResult(result: DownloadResult, id: Int64) {
        print("\(DownloadBridge.TAG) invokeResult: id: \(id)")
        
        DispatchQueue.main.async {
            self.batteryChannel?.invokeMethod(ChannelTag.eventBridge, arguments: result.toMap())
        }
    }
    
    func dispose() {
        print("\(DownloadBridge.TAG) dispose")
    }
}
