//
//  DownloadStatus 2.swift
//  Developer
//
//  Created by Nguyễn Minh Hưng on 5/5/26.
//


enum DownloadStatus {
    case idle
    case pending
    case inProgress
    case completed
    case failed
    case canceled
    case paused
}


extension DownloadStatus {
    let isInProgress: Bool = self == .inProgress
    
    let isCompleted: Bool = self == .completed
}
