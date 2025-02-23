//
//  DIDUrl.swift
//  
//
//  Created by Gonçalo Frade on 14/08/2023.
//

import Foundation

public struct DIDUrl: Sendable, Hashable, Equatable {
    public let did: DID
    public let queries: [String: String]
    public let path: String?
    public let fragment: String?
    
    public init(did: DID, queries: [String: String], path: String?, fragment: String?) {
        self.did = did
        self.queries = queries
        self.path = path
        self.fragment = fragment
    }
    
    public init?(from string: String) {
        let regexPattern = #"^did:([^:/?#]+):([^?#]*)(?:\?([^#]*))?(?:#(.*))?$"#
        let regex = try? NSRegularExpression(pattern: regexPattern)
        guard let match = regex?.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)) else {
            return nil
        }
        
        // Extract DID Method
        guard let methodRange = Range(match.range(at: 1), in: string) else {
            return nil
        }
        let method = String(string[methodRange])
        
        // Extract methodId and path from the second capturing group
        guard let fullMethodIdRange = Range(match.range(at: 2), in: string) else {
            return nil
        }
        let fullMethodIdComponents = string[fullMethodIdRange].split(separator: "/", maxSplits: 1)
        let methodId = String(fullMethodIdComponents[0])
        let path = fullMethodIdComponents.count > 1 ? "/" + String(fullMethodIdComponents[1]) : nil
        
        // Construct the DID instance
        did = DID(schema: "did", method: method, methodId: methodId)
        
        // Extract Queries
        if let queriesRange = Range(match.range(at: 3), in: string) {
            let queryString = String(string[queriesRange])
            let queryPairs = queryString.split(separator: "&").map { $0.split(separator: "=") }
            var queries: [String: String] = [:]
            for pair in queryPairs {
                if pair.count == 2 {
                    queries[String(pair[0])] = String(pair[1])
                }
            }
            self.queries = queries
        } else {
            self.queries = [:]
        }
        
        self.path = path
        
        // Extract Fragment
        if let fragmentRange = Range(match.range(at: 4), in: string) {
            self.fragment = String(string[fragmentRange])
        } else {
            self.fragment = nil
        }
    }
}

extension DIDUrl: Identifiable {
    public var id: String {
        description
    }
}

extension DIDUrl: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        guard let didUrl = DIDUrl(from: value) else {
            fatalError("Invalid DIDUrl string literal: \(value)")
        }
        self = didUrl
    }
}

extension DIDUrl: CustomStringConvertible {
    public var description: String {
        guard var url = URLComponents(string: did.description) else { return "" }
        if let path { url.path = path }
        url.queryItems = queries.map { .init(name: $0, value: $1) }
        url.fragment = fragment
        return url.string ?? ""
    }
}
