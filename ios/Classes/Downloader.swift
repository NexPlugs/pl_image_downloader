//
//  Downloader.swift
//
//  Created by Nguyễn Minh Hưng on 8/5/26.
//

import Photos
import Flutter

let DOWNLOAD_DELAY: UInt64 = 1_000_000_000

// Downloader is responsible for managing the download process of a single DownloadTask, including starting, pausing, resuming, and canceling the download. It also handles progress updates and saving the downloaded image to the photo library or documents directory based on permissions.
class Downloader {
    static private let TAG = "Downloader"
    
    private var session: URLSession? = nil
    
    private var downloadTaskNative: URLSessionDownloadTask? = nil
    private var progressTimer: Timer?
    private var downloadCallBack: ((DownloadTask) -> Void)? = nil
    
    private(set) var downloadTask: DownloadTask {
        didSet {
            downloadCallBack?(downloadTask)
        }
    }
    
    var status: DownloadStatus {
        downloadTask.downloadStatus
    }
    

    
    init(
        downloadInfo: DownloadInfo? = nil,
        initTask: DownloadTask? = nil,
    ) {
        precondition(downloadInfo != nil || initTask != nil, "Either downloadInfo or initTask must be provided.")
        
        print("\(Downloader.TAG) init with downloadInfo: \(String(describing: downloadInfo)) initTask: \(String(describing: initTask))")
        
        self.downloadTask = initTask ?? DownloadTask.fromDownloadInfo(downloadInfo!)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 300
        
        self.session = URLSession(
            configuration: configuration,
            delegate: nil,
            delegateQueue: .main
        )
    }
    
    
    @discardableResult
    func setDownloadCallBack(
        _ callBack: @escaping (DownloadTask) -> Void
    ) -> Self {
        downloadCallBack = callBack
        return self
    }
    
    private func factoryError(
        message: String
    ) {
        NSLog("\(Downloader.TAG) factoryError: \(message)")
        downloadTask = downloadTask.failed(errorMessage: message)
    }
    
    func executeDownload() {
        if status.isInProgress { return }
        
        guard let session = session else { return }

        downloadTask = downloadTask.copy(downloadStatus: .inProgress)
        
        if downloadTask.url.isEmpty {
            factoryError(
                message: "Download URL is empty for task id: \(String(describing: downloadTask.id))"
            )
            return
        }

        guard let url = URL(string: downloadTask.url) else {
            factoryError(
                message: "Invalid URL: \(downloadTask.url) for task id: \(String(describing: downloadTask.id))"
            )
            return
        }
        

        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) {
            [weak self] tempUrl, response, error in
            guard let self = self else { return }
            
            NSLog("\(Downloader.TAG) Download complete but temporary file URL is nil for task id: \(String(describing: self.downloadTask.id))")
            
            if let error = error {
                self.factoryError(
                    message: "Download failed with error: \(error.localizedDescription) for task id: \(String(describing: self.downloadTask.id))"
                )
                return
            }
            
            guard let tempUrl = tempUrl else {
                self.factoryError(
                    message: "Download failed: Temporary file URL is nil for task id: \(String(describing: self.downloadTask.id))"
                )
                return
            }
            
            guard let data = try? Data(contentsOf: tempUrl),
                  let image = UIImage(data: data) else {
                self.factoryError(
                    message: "Download failed: Unable to read downloaded data as image for task id: \(String(describing: self.downloadTask.id))"
                )
                return
            }
            
            self.checkPermissionAndSave(
                image: image,
                fileName: self.downloadTask.fileName,
                saveSuccess: { savedPath in
                    self.downloadTask = self.downloadTask.copy(
                        destinationPath: savedPath,
                    ).success()
                },
                saveFailed: { error in
                    self.factoryError(message: error)
                }
            )
        }
        
        // Keep a reference if you intend to pause/resume/cancel later
        self.downloadTaskNative = task
        startTradeProgress()

        self.downloadTaskNative?.resume()
    }
    
    private func checkPermissionAndSave(
        image: UIImage,
        fileName: String,
        saveSuccess: @escaping (String) -> Void,
        saveFailed: @escaping (String) -> Void
    ) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            var hasPermission = false
            switch status {
            case .authorized:
                hasPermission = true
            default:
                if #available(iOS 14, *) {
                    hasPermission = true
                }
            }
            
            if hasPermission {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { success, error in
                    if success {
                        // NOTE: In the future, we can enhance this to retrieve the actual file path of the saved image in the photo library if needed.
                        saveSuccess(fileName)
                    } else {
                        saveFailed("Failed to save image to photo library for task id: \(String(describing: self.downloadTask.id)) with error: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else {
                // If permission is not granted, attempt to save to documents directory as a fallback
                do {
                    let savedPath = try self.saveImageToDocuments(image: image, fileName: fileName)
                    saveSuccess(savedPath)
                } catch {
                    saveFailed("Failed to save image to documents directory for task id: \(String(describing: self.downloadTask.id)) with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func startTradeProgress() {
        if !status.isInProgress { return }
        
        stopTradeProgress()
        
        progressTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            let progress = self.getProgress()
            print("\(Downloader.TAG) progressTimer progress: \(progress) for task id: \(String(describing: self.downloadTask.id))")
            self.downloadTask = self.downloadTask.copy(progress: progress)
        }
    }
    
    private func stopTradeProgress() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func saveImageToDocuments(
        image: UIImage,
        fileName: String,
    ) throws -> String{
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw NSError(
                domain: "Downloader",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to access document directory for task id: \(String(describing: downloadTask.id))"
                ]
            )
        }
        
        let fileUrl = documentDirectory.appendingPathComponent(fileName)
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            throw NSError(
                domain: "Downloader",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to convert image to data for task id: \(String(describing: downloadTask.id))"
                ]
            )
        }
        
        do {
            try imageData.write(to: fileUrl)
            
            return fileUrl.path
        } catch {
            throw error
        }
    }
    
    
    func executePause() {
        if status.isInProgress {
            downloadTaskNative?.suspend()
            downloadTask = downloadTask.copy(downloadStatus: .paused)
        }
    }
    
    func executeResume() {
        if status == .paused {
            downloadTaskNative?.resume()
            downloadTask = downloadTask.copy(downloadStatus: .inProgress)
        }
    }
    
    func cancel() {
        stopTradeProgress()
        
        downloadTaskNative?.cancel()
        downloadTask = downloadTask.copy(downloadStatus: .canceled)
    }
    
    
    private func getProgress() -> Int {
        guard let downloadTaskNative = downloadTaskNative else { return 0 }
        let completed = downloadTaskNative.countOfBytesReceived
        let total = downloadTaskNative.countOfBytesExpectedToReceive
        
        if total > 0 {
            return Int((Double(completed) / Double(total)) * 100)
        }
        
        let progress = Double(completed) / Double(total)
        return Int(progress * 100)
    }
}
