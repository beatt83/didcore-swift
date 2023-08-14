//
//  JWK.swift
//  
//
//  Created by Gonçalo Frade on 13/08/2023.
//
import Base64
import Foundation

public struct JWK {
    // Common properties
    public let kty: String               // Key type
    public let use: String?              // Public key use parameter (sig, enc)
    public let key_ops: [String]?        // Key Operations
    public let alg: String?              // Algorithm intended for use with the key
    public let kid: String?              // Key ID
    public let x5u: URL?                 // X.509 URL
    public let x5c: [String]?            // X.509 certificate chain
    public let x5t: String?              // X.509 certificate SHA-1 thumbprint
    public let x5t_S256: String?         // X.509 certificate SHA-256 thumbprint

    // For RSA keys
    public let n: String?                // RSA modulus
    public let e: String?                // RSA exponent

    // For Elliptic Curve keys
    public let crv: String?              // EC Curve
    public let x: String?                // EC X coordinate
    public let y: String?                // EC Y coordinate
    public let d: String?                // EC private key

    // For Octet key (symmetric)
    public let k: String?                // Key value
    
    init(
        kty: String,
        use: String? = nil,
        key_ops: [String]? = nil,
        alg: String? = nil,
        kid: String? = nil,
        x5u: URL? = nil,
        x5c: [String]? = nil,
        x5t: String? = nil,
        x5t_S256: String? = nil,
        n: String? = nil,
        e: String? = nil,
        crv: String? = nil,
        x: String? = nil,
        y: String? = nil,
        d: String? = nil,
        k: String? = nil
    ) {
        self.kty = kty
        self.use = use
        self.key_ops = key_ops
        self.alg = alg
        self.kid = kid
        self.x5u = x5u
        self.x5c = x5c
        self.x5t = x5t
        self.x5t_S256 = x5t_S256
        self.n = n
        self.e = e
        self.crv = crv
        self.x = x
        self.y = y
        self.d = d
        self.k = k
    }
}

extension JWK {
    init(key: Data, type: KnownVerificationMaterialType) throws {
        let kty = "OKP"
        let x = key.base64URLEncoded(padded: false)
        let crv: String
        switch type {
        case .agreement(.jsonWebKey2020):
            crv = "X25519"
        case .authentication(.jsonWebKey2020):
            crv = "Ed25519"
        default:
            throw DIDCoreError.invalidJWKMaterialType(type.rawValue)
        }
        self.init(kty: kty, crv: crv, x: x)
    }
}

extension JWK: Codable {}
