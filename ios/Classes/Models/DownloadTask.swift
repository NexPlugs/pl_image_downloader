//
//  DownloadTask.swift
//

import Foundation

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

        let directory = URL(fileURLWithPath: destinationPath)
            .deletingLastPathComponent()
            .path

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
                dictionary: directory,
                fileName: fileName,
                isSuccess: true,
                error: nil
            )
        )
    }

    func failed(errorMessage: String? = nil) -> DownloadTask {

        let directory = URL(fileURLWithPath: destinationPath)
            .deletingLastPathComponent()
            .path

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
                dictionary: directory,
                fileName: fileName,
                isSuccess: false,
                error: errorMessage ?? "Unknown error occurred during download."
            )
        )
    }
    
    func copy(
        id: Int64?? = nil,
        enqueueId: Int64?? = nil,
        url: String? = nil,
        destinationPath: String? = nil,
        fileName: String? = nil,
        overwrite: Bool? = nil,
        downloadStatus: DownloadStatus? = nil,
        progress: Int? = nil,
        result: DownloadResult?? = nil
    ) -> DownloadTask {
        return DownloadTask(
            id: id ?? self.id,
            enqueueId: enqueueId ?? self.enqueueId,
            url: url ?? self.url,
            destinationPath: destinationPath ?? self.destinationPath,
            fileName: fileName ?? self.fileName,
            overwrite: overwrite ?? self.overwrite,
            downloadStatus: downloadStatus ?? self.downloadStatus,
            progress: progress ?? self.progress,
            result: result ?? self.result
        )
    }
}
