//
//  DownloadHandler.swift
//
//  Created by Nguyễn Minh Hưng on 8/5/26.
//

import Flutter

class DownloadHandler {
    static private let TAG = "DownloadHandler"
    
    private var bridge: DownloadBridge? = nil
    
    private var activeDownloaders = [Int64: Downloader]()
    
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
        
        if task.downloadStatus == .failed || task.downloadStatus == .completed {
            activeDownloaders.removeValue(forKey: id)
        }
                    
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
        let info = argument.toDownloadInfo()
        
        guard let taskId = info.id else { return }
        
        
        let downloader = Downloader(downloadInfo: info)
            .setDownloadCallBack { [weak self] downloadTask in
                guard let self = self else { return }
                self.handleDownloadCallBack(
                    task: downloadTask,
                    errorLogBack: errorLogBack,
                    result: result
                )
            }
        
        activeDownloaders[taskId] = downloader
        
        downloader.executeDownload()
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
        
        // Remove all active downloaders and cancel their tasks
        activeDownloaders.forEach { $0.value.cancel() }
        activeDownloaders.removeAll()
    }
    
    
    func doAction(
        method: String,
        arguments: [String: Any]?,
        result: @escaping FlutterResult,
        errorLogBack: @escaping (String) -> Void
    ) {
        print("\(DownloadHandler.TAG) doAction method: \(method) arguments: \(String(describing: arguments))")
        
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
