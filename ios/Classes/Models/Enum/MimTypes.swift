//
//  MimTypes.swift
//  Developer
//
//  Created by Nguyễn Minh Hưng on 5/5/26.
//

public enum MimeTypes: String, CaseIterable {
    case imageJpeg = "image/jpeg"
    case imagePng = "image/png"
    case imageGif = "image/gif"
    case imageSvgXml = "image/svg+xml"
    case imageBmp = "image/bmp"
}

public extension MimeTypes {
    
    static func fromValue(_ name: String) throws -> MimeTypes {
        if let match = Self.allCases.first(where: {
            $0.rawValue.lowercased() == name.lowercased()
        }) {
            return match
        }
        return .imageJpeg
        
    }
}
