//
//  DownloadCallBack.swift
//  
//
//  Created by Nguyễn Minh Hưng on 5/5/26.
//
public protocol DownloadResultProtocol {
    func toMap() -> [String: Any]
}

public enum DownloadCallBack {
    case onProgress(value: Int, id: Int64)
    case onComplete(value: DownloadResultProtocol, id: Int64)
}

extension DownloadCallBack {
    func toMap() -> [String: Any] {
        switch self {
        case .onProgress(let value, let id):
            return [
                "method": "progress",
                "value": value,
                "id": id
            ]
        case .onComplete(let value, let id):
            return [
                "method": "result",
                "value": value.toMap(),
                "id": id
            ]
        }
    }
}


