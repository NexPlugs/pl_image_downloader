//
//  DownloadHandler.swift
//
//  Created by Nguyễn Minh Hưng on 8/5/26.
//

struct DownloadHandler {
    static private let TAG = "DownloadHandler"
    
    private var bridge: DownloadBridge? = nil
    
    public init(
        messenger: FlutterBinaryMessenger
    ) {
        bridge = DownloadBridge(messenger:  messenger)
    }
    
    private func updateDownloadConfig(
        arguments: [String: Any],
        result: @escaping FlutterResult,
    ) {
        
    }
    
    private func handleDownloadCallBack(
        task: DownloadTask,
        errorLogBack: @escaping (String) -> Void,
        result: @escaping FlutterResult
    ) {
        
        guard let id = task.id, let bridge = bridge else { return }
        
        switch task.downloadStatus {
        case .inProgress:
            let progress = task.progress
            print("\(DownloadHandler.TAG) handleDownloadCallBack progress: \(progress) id: \(id)")
            bridge.invokeProgress(progress: progress, id: id)
        case .completed:
            guard let result = task.result else { return }
            print("\(DownloadHandler.TAG) handleDownloadCallBack completed id: \(id)")
            bridge.invokeResult(result: result, id: id)
        case .failed:
            print("\(DownloadHandler.TAG) handleDownloadCallBack failed id: \(id)")
            errorLogBack("Download failed for task id: \(id)")
        default:
            break
        }
        
    }
    
    
    private func handleDownload(
        argument: [String: Any],
        result: @escaping FlutterResult,
        errorLogBack: @escaping (String) -> Void
    ) {
        
    }
    
    
    private func handleDownloadServiceTag(
        argument: [String: Any],
        result: @escaping FlutterResult,
    ) {
        
    }
    
    private func handleServiceDispose(
        result: @escaping FlutterResult,
    ) {
        bridge?.dispose()
    }
    
    
    func doAction(
        method: String,
        arguments: [String: Any]?,
        result: @escaping FlutterResult,
        errorLogBack: @escaping (String) -> Void
    ) {
        
        switch method {
        case ChannelTag.downloadConfig:
            guard let arguments = arguments else { return }
            updateDownloadConfig(arguments: arguments, result: result)
        case ChannelTag.download:
            guard let arguments = arguments else { return }
            handleDownload(argument: arguments, result: result, errorLogBack: errorLogBack)
        case ChannelTag.downloadServiceTag:
            guard let arguments = arguments else { return }
            handleDownloadServiceTag(argument: arguments, result: result)
        case ChannelTag.serviceDisposeTag:
            handleServiceDispose(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
