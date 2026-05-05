//
//  DownloadInfo.swift
//  Developer
//
//  Created by Nguyễn Minh Hưng on 5/5/26.
//

public struct DownloadInfo {
    var id: Int64? = nil
    var url: String = ""
    var fileName: String = ""
    var fileSize: Int64? = nil
}


public extension Dictionary where Key == String, Value == Any {
    func toDownloadInfo() -> DownloadInfo {
        return DownloadInfo(
            id: self["id"] as? Int64,
            url: self["url"] as? String ?? "",
            fileName: self["fileName"] as? String ?? "",
            fileSize: self["fileSize"] as? Int64
        )
    }
}
