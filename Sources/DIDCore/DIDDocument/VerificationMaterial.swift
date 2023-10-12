//
//  VerificationMaterial.swift
//  
//
//  Created by Gonçalo Frade on 13/08/2023.
//

import BaseX
import Multibase
import Foundation

public enum VerificationMaterialFormat: String, Codable {
    case jwk
    case base58
    case multibase
}

public enum KnownVerificationMaterialType: RawRepresentable, Codable {
    
    public enum AgreementType: String, Codable {
        case jsonWebKey2020 = "JsonWebKey2020"
        case x25519KeyAgreementKey2019 = "X25519KeyAgreementKey2019"
        case x25519KeyAgreementKey2020 = "X25519KeyAgreementKey2020"
    }
    
    public enum AuthenticationType: String, Codable {
        case jsonWebKey2020 = "JsonWebKey2020"
        case ed25519VerificationKey2018 = "Ed25519VerificationKey2018"
        case ed25519VerificationKey2020 = "Ed25519VerificationKey2020"
        case ecdsaSecp256k1VerificationKey2019 = "EcdsaSecp256k1VerificationKey2019"
        case bls12381G1Key2020 = "Bls12381G1Key2020"
        case bls12382G2Key2020 = "Bls12382G2Key2020"
        case pgpVerificationKey2021 = "PgpVerificationKey2021"
        case ecdsaSecp256k1RecoveryMethod2020 = "EcdsaSecp256k1RecoveryMethod2020"
        case verifiableCondition2021 = "VerifiableCondition2021"
    }
    
    case agreement(AgreementType)
    case authentication(AuthenticationType)
    
    public init?(rawValue: String) {
        if let agreementType = AgreementType(rawValue: rawValue) {
            self = .agreement(agreementType)
        } else if let autheticationType = AuthenticationType(rawValue: rawValue) {
            self = .authentication(autheticationType)
        } else {
            return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .agreement(let type):
            return type.rawValue
        case .authentication(let type):
            return type.rawValue
        }
    }
    
    var isAuthentication: Bool {
        switch self {
        case .agreement:
            return false
        case .authentication:
            return true
        }
    }
    
    var isAgreement: Bool {
        switch self {
        case .agreement:
            return true
        case .authentication:
            return false
        }
    }
}

public struct VerificationMaterial {
    public let format: VerificationMaterialFormat
    public let value: Data
    
    public init(format: VerificationMaterialFormat, value: Data) {
        self.format = format
        self.value = value
    }
}

extension VerificationMaterial: Codable {}

extension VerificationMaterial {
    
    public static func fromJWK(jwk: JWK) throws -> VerificationMaterial {
        let encoder = JSONEncoder.DIDDocumentEncoder()
        
        return .init(
            format: .jwk,
            value: try encoder.encode(jwk)
        )
    }
    
    public static func fromKeyToMultibase(key: Data, codec: Multicodec.Codec) throws -> VerificationMaterial {
        let multicodec = Multicodec().toMulticodec(value: key, codec: codec)
        guard let multibase = BaseEncoding.base58btc.encode(data: multicodec).data(using: .utf8) else {
            throw DIDCoreError.somethingWentWrong
        }
        return .init(
            format: .multibase,
            value: multibase
        )
    }
    
    public static func fromKeyToBase58(key: Data) throws -> VerificationMaterial {
        guard let encoded = BaseX.encode(key, into: .base58BTC).data(using: .utf8) else {
            throw DIDCoreError.somethingWentWrong
        }
        
        return .init(
            format: .jwk,
            value: encoded
        )
    }
    
    public init(format: VerificationMaterialFormat, key: Data, type: KnownVerificationMaterialType) throws {
        self.format = format
        switch format {
        case .jwk:
            let jwk = try JWK(key: key, type: type)
            let encoder = JSONEncoder.DIDDocumentEncoder()
            self.value = try encoder.encode(jwk)
        case .base58:
            guard let encoded = BaseX.encode(key, into: .base58BTC).data(using: .utf8) else {
                throw DIDCoreError.somethingWentWrong
            }
            self.value = encoded
        case .multibase:
            let multicodec = Multicodec().toMulticodec(value: key, keyType: type)
            guard let multibase = BaseEncoding.base58btc.encode(data: multicodec).data(using: .utf8) else {
                throw DIDCoreError.somethingWentWrong
            }
            self.value = multibase
        }
    }
    
    public func decodedKey() throws -> Data {
        switch format {
        case .jwk:
            let decoder = JSONDecoder()
            let jwk = try decoder.decode(JWK.self, from: value)
            guard
                let x = jwk.x,
                let decoded = Data(base64URLEncoded: x)
            else {
                throw DIDCoreError.unsupportedJWKKeyDecoding
            }
            return decoded
        case .base58:
            guard let base58Str = String(data: value, encoding: .utf8) else {
                throw DIDCoreError.invalidBase64URLKey
            }
            return try BaseX.decode(base58Str, as: .base58BTC)
        case .multibase:
            guard let multibaseStr = String(data: value, encoding: .utf8) else {
                throw DIDCoreError.invalidBase64URLKey
            }
            let multibaseDecoded = try BaseEncoding.decode(multibaseStr).data
            return try Multicodec().fromMulticodec(value: multibaseDecoded).data
        }
    }
    
    public func convertToBase58(type: KnownVerificationMaterialType) throws -> VerificationMaterial {
        guard self.format != .base58 else { return self }
        
        let newType: KnownVerificationMaterialType
        switch type {
        case .agreement:
            newType = .agreement(.x25519KeyAgreementKey2019)
        case .authentication:
            newType = .authentication(.ed25519VerificationKey2018)
        }
        
        return try .init(format: .base58, key: try self.decodedKey(), type: newType)
    }
    
    public func convertToJWK(type: KnownVerificationMaterialType) throws -> VerificationMaterial {
        guard self.format != .jwk else { return self }
        
        let newType: KnownVerificationMaterialType
        switch type {
        case .agreement:
            newType = .agreement(.jsonWebKey2020)
        case .authentication:
            newType = .authentication(.jsonWebKey2020)
        }
        
        return try .init(format: .jwk, key: try self.decodedKey(), type: newType)
    }
    
    public func convertToMultibase(type: KnownVerificationMaterialType) throws -> VerificationMaterial {
        guard self.format != .multibase else { return self }
        
        let newType: KnownVerificationMaterialType
        switch type {
        case .agreement:
            newType = .agreement(.x25519KeyAgreementKey2020)
        case .authentication:
            newType = .authentication(.ed25519VerificationKey2020)
        }
        
        return try .init(format: .multibase, key: try self.decodedKey(), type: newType)
    }
}
