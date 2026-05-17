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
        //TODO: Will implement in the future when we need to update download config
    }
        
    private func handleDownloadCallBack(
        task: DownloadTask,
        errorLogBack: @escaping (String) -> Void,
        result: @escaping FlutterResult
    ) {
        
        guard let id = task.id, let bridge = bridge else { return }
        
        if task.downloadStatus == .failed || task.downloadStatus == .completed {
            activeDownloaders[id]?.cancel()
            activeDownloaders.removeValue(forKey: id)
        }
                    
        switch task.downloadStatus {
        case .inProgress:
            let progress = task.progress
            NSLog("\(DownloadHandler.TAG) handleDownloadCallBack progress: \(progress) id: \(id)")
            bridge.invokeProgress(progress: progress, id: id)
        case .completed:
            guard let resultData = task.result else { return }
            NSLog("\(DownloadHandler.TAG) handleDownloadCallBack completed id: \(id)")
            bridge.invokeResult(result: resultData, id: id)
            
            DispatchQueue.main.sync {
                result(resultData.toMap())
            }
        case .failed:
            NSLog("\(DownloadHandler.TAG) handleDownloadCallBack failed id: \(id)")
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
                guard let self = self else {
                    NSLog("\(DownloadHandler.TAG) handleDownload downloadCallBack self is nil")
                    return
                }
                self.handleDownloadCallBack(
                    task: downloadTask,
                    errorLogBack: errorLogBack,
                    result: result
                )
                
            }
        
        activeDownloaders[taskId] = downloader
        
        downloader.executeDownload()
    }
    
    private func handleDownloadPause(
        argument: [String: Any],
        result: @escaping FlutterResult,
        errorLogBack: @escaping (String) -> Void
    ) {
        guard let id = argument["id"] as? Int64 else {
            errorLogBack("Invalid argument: missing 'id' for pause download")
            return
        }
        
        guard let downloader = activeDownloaders[id] else {
            errorLogBack("No active downloader found for id: \(id) to pause")
            return
        }
        
        if !downloader.status.isInProgress {
            errorLogBack("Downloader with id: \(id) is not in a state that can be paused")
            return
        }
        
        downloader.executePause()
        DispatchQueue.main.async { result(true) }
    }
    
    private func handleDownloadResume(
        argument: [String: Any],
        result: @escaping FlutterResult,
        errorLogBack: @escaping (String) -> Void
    ) {
        guard let id = argument["id"] as? Int64 else {
            errorLogBack("Invalid argument: missing 'id' for resume download")
            return
        }
        
        guard let downloader = activeDownloaders[id] else {
            errorLogBack("No active downloader found for id: \(id) to resume")
            return
        }
        
        if !downloader.status.isPaused {
            errorLogBack("Downloader with id: \(id) is not in a paused state and cannot be resumed")
            return
        }
        
        downloader.executeResume()
        DispatchQueue.main.async { result(true) }
    }
    
    private func handleDownloadCancel(
        argument: [String: Any],
        result: @escaping FlutterResult,
        errorLogBack: @escaping (String) -> Void
    ) {
        guard let id = argument["id"] as? Int64 else {
            errorLogBack("Invalid argument: missing 'id' for cancel download")
            return
        }
        
        guard let downloader = activeDownloaders[id] else {
            errorLogBack("No active downloader found for id: \(id) to cancel")
            return
        }
        
        downloader.cancel()
        activeDownloaders.removeValue(forKey: id)
        
        DispatchQueue.main.async { result(true) }
    }
    
    
    private func handleDownloadServiceTag(
        argument: [String: Any],
        result: @escaping FlutterResult,
    ) {
        //TODO: Will implement in the future when we need to handle multiple downloaders in the service
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
        case ChannelTag.downloadPause:
            guard let arguments = arguments else { return }
            handleDownloadPause(argument: arguments, result: result, errorLogBack: errorLogBack)
        case ChannelTag.downloadResume:
            guard let arguments = arguments else { return }
            handleDownloadResume(argument: arguments, result: result, errorLogBack: errorLogBack)
        case ChannelTag.downloadCancel:
            guard let arguments = arguments else { return }
            handleDownloadCancel(argument: arguments, result: result, errorLogBack: errorLogBack)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
