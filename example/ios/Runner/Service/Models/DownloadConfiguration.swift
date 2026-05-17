//
//  DownloadConfiguration.swift
//

import Foundation

public struct DownloadConfiguration {

    public let saveName: String?
    public let downloadMode: DownloadMode
    public let mimTypes: MimeTypes
    public let retryCount: Int

    public init(
        saveName: String? = nil,
        downloadMode: DownloadMode = .normal,
        mimTypes: MimeTypes = .imageJpeg,
        retryCount: Int = 3
    ) {
        self.saveName = saveName
        self.downloadMode = downloadMode
        self.mimTypes = mimTypes
        self.retryCount = retryCount
    }
}

public extension DownloadConfiguration {

    static func `default`() -> DownloadConfiguration {
        DownloadConfiguration()
    }

    var isNormalMode: Bool {
        return downloadMode == .normal
    }

    var isBackgroundMode: Bool {
        return downloadMode == .runningBackgroundService
    }
}

public extension Dictionary where Key == String, Value == Any {

    func toDownloadConfiguration() -> DownloadConfiguration {

        let modeString = self["downloadMode"] as? String
        let mimeString = self["mimTypes"] as? String

        return DownloadConfiguration(
            saveName: self["saveName"] as? String,
            downloadMode: modeString
                .flatMap { DownloadMode(rawValue: $0) } ?? .normal,
            mimTypes: mimeString
                .flatMap { MimeTypes(rawValue: $0) } ?? .imageJpeg,
            retryCount: self["retryCount"] as? Int ?? 3
        )
    }
}
