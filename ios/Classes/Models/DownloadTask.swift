//
//  DownloadTask.swift
//
//  Created by Nguyễn Minh Hưng on 5/5/26.
//

struct DownloadTask {
    
    let id: Int64?
    let enqueueId: Int64?
    let url: String
    let destinationPath: String
    let fileName: String
    let overwrite: Bool
    let downloadStatus: DownloadStatus
    let progress: Int
    
    
    /// Result of the download operation.
    let result: DownloadResult?
    
    init(
        id: Int64? = nil,
        enqueueId: Int64? = nil,
        url: String,
        destinationPath: String = "",
        fileName: String,
        overwrite: Bool = false,
        downloadStatus: DownloadStatus = .idle,
        progress: Int = 0,
        result: DownloadResult? = nil
    ) {
        self.id = id
        self.enqueueId = enqueueId
        self.url = url
        self.destinationPath = destinationPath
        self.fileName = fileName
        self.overwrite = overwrite
        self.downloadStatus = downloadStatus
        self.progress = progress
        self.result = result
    }
}

extension DownloadTask {
    
    static func fromDownloadInfo(_ info: DownloadInfo) -> DownloadTask {
        return DownloadTask(
            id: info.id,
            url: info.url,
            fileName: info.fileName
        )
    }
    
    func success() -> DownloadTask {
        return DownloadTask(
            id: id,
            enqueueId: enqueueId,
            url: url,
            destinationPath: destinationPath,
            fileName: fileName,
            overwrite: overwrite,
            downloadStatus: .completed,
            progress: 100,
            result: DownloadResult(
                path: destinationPath,
                dictionary: destinationPath.deletingLastPathComponent,
                fileName: fileName,
                isSuccess: true,
                errorMessage: nil
            )
        )
    }
    
    func failed(errorMessage: String? = nil) -> DownloadTask {
        
        return DownloadTask(
            id: id,
            enqueueId: enqueueId,
            url: url,
            destinationPath: destinationPath,
            fileName: fileName,
            overwrite: overwrite,
            downloadStatus: .failed,
            progress: progress,
            result: DownloadResult(
                path: destinationPath,
                dictionary: destinationPath.deletingLastPathComponent,
                fileName: fileName,
                isSuccess: false,
                errorMessage: errorMessage ?? "Unknown error occurred during download."
            )
        )
    }
}
}
