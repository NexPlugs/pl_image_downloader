//
//  DownloadConfiguration.swift
//  Developer
//
//  Created by Nguyễn Minh Hưng on 5/5/26.
//


public struct DownloadConfiguration {
    let saveName: String? = nil
    let downloadMode: DownloadMode = .normal
    let mimTypes: MimeTypes = .imageJpeg
    let retryCount: Int = 3
}


public extension DownloadConfiguration {
    let default: DownloadConfiguration = DownloadConfiguration()
    
    let isNormalMode: Bool = downloadMode == .normal
    
    let isBackgroundMode: Bool = downloadMode == .background
    
    let
}

public extension Dictionary where Key == String, Value == Any {
    func toDownloadConfiguration() -> DownloadConfiguration {
        return DownloadConfiguration(
            saveName: self["saveName"] as? String,
            downloadMode: (self["downloadMode"] as? String).flatMap { DownloadMode(rawValue: $0) } ?? .normal,
            mimTypes: (self["mimTypes"] as? String).flatMap { MimeTypes(rawValue: $0) } ?? .imageJpeg,
            retryCount: self["retryCount"] as? Int ?? 3
        )
    }
}
