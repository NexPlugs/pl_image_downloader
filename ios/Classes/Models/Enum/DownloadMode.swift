//
//  DownloadMode.swift
//  Developer
//
//  Created by Nguyễn Minh Hưng on 5/5/26.
//

public enum DownloadMode: String {
    case normal = "normal"
    case runningBackgroundService = "runningBackgroundService"
}

public extension DownloadMode {
    static func fromValue(_ name: String) -> Self {
        if let match = Self.allCases.first(where: {
            $0.rawValue.lowercased() == name.lowercased()
        }) {
            return match
        }
        return .normal
    }
}


