//
//  DownloadCallBack.swift
//  
//
//  Created by Nguyễn Minh Hưng on 5/5/26.
//
protocol DownloadResultProtocol {
    func toMap() -> [String: Any]
}

public enum DownloadCallBack {
    case onProgress(value: Int, id: Int64)
    case result(value: DownloadResultProtocol, id: Int64)
}


