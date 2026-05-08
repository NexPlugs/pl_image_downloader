//
//  DownloadResult.swift
//  Developer
//
//  Created by Nguyễn Minh Hưng on 5/5/26.
//

public struct DownloadResult {
    var path: String = ""
    var dictionary: String = ""
    var fileName: String = ""
    var isSuccess: Bool = false
    var error: String? = null
}


public extension DownloadResult {
    func toMap() -> [String: Any] {
        var map = [String: Any](
            "path", path,
            "directoryResult", dictionary,
            "fileName", fileName,
            "isSuccess", isSuccess,
        )
        if let error = error {
            map["errorMessage"] = error
        }
        return map
    }
}
