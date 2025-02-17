//
//  DID.swift
//  
//
//  Created by Gonçalo Frade on 14/08/2023.
//

import Foundation

public struct DID: Sendable, Hashable, Equatable {
    public let schema: String
    public let method: String
    public let methodId: String
    
    public init(schema: String, method: String, methodId: String) {
        self.schema = schema
        self.method = method
        self.methodId = methodId
    }
    
    public init?(from string: String) {
        let pattern = "^did:([a-z0-9]+):([\\w\\.\\-\\%]+)$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let matches = regex?.matches(in: string, options: [], range: NSRange(string.startIndex..., in: string))
        
        guard let match = matches?.first, match.numberOfRanges == 3 else {
            return nil
        }
        
        guard let methodRange = Range(match.range(at: 1), in: string),
              let methodIdRange = Range(match.range(at: 2), in: string) else {
            return nil
        }
        
        self.schema = "did"
        self.method = String(string[methodRange])
        self.methodId = String(string[methodIdRange])
    }
}

extension DID: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        guard let did = DID(from: value) else {
            fatalError("Invalid DID string literal: \(value)")
        }
        self = did
    }
}

extension DID: CustomStringConvertible {
    public var description: String {
        return "\(schema):\(method):\(methodId)"
    }
}
