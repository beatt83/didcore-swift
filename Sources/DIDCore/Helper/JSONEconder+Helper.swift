//
//  JSONEconder+Helper.swift
//  
//
//  Created by Gonçalo Frade on 14/08/2023.
//

import Foundation

extension JSONEncoder {
    static func DIDDocumentEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            encoder.outputFormatting = [.withoutEscapingSlashes, .sortedKeys]
        } else {
            encoder.outputFormatting = .sortedKeys
        }
        return encoder
    }
}
