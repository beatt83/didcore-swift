//
//  DIDDocument.swift
//
//
//  Created by Gonçalo Frade on 13/08/2023.
//
import BaseX
import Foundation

public struct DIDDocument {
    
    public struct VerificationMethod: Sendable, Hashable, Equatable {
        public let id: String
        public let controller: String
        public let type: String
        public let material: VerificationMaterial
        
        public init(
            id: String,
            controller: String,
            type: String,
            material: VerificationMaterial
        ) {
            self.id = id
            self.controller = controller
            self.type = type
            self.material = material
        }
    }
    
    // Service may contain extensions, with this in mind this Service model is the basic structure of a Service as described in [did-core](https://www.w3.org/TR/did-core/#services). But the DIDDocument itself uses AnyCodable for the service.
    public struct Service {
        public let id: String
        public let type: String
        // Its not ideal that the service endpoint is a AnyCodable but since by the specification we cannot know the structure of the serviceEndpoint structure this is the best way.
        public let serviceEndpoint: AnyCodable
        
        public init(
            id: String,
            type: String,
            serviceEndpoint: AnyCodable
        ) {
            self.id = id
            self.type = type
            self.serviceEndpoint = serviceEndpoint
        }
        
        public init(from: AnyCodable) throws {
            guard
                let value = from.value as? [String: Any],
                let id = value["id"] as? String,
                let type = value["type"] as? String,
                let serviceEndpoint = value["serviceEndpoint"]
            else {
                throw DIDCoreError.somethingWentWrong
            }
            self.id = id
            self.type = type
            self.serviceEndpoint = AnyCodable(serviceEndpoint)
        }
    }
    
    public enum VerificationMethodMapping {
        case stringValue(String)
        case verificationMethod(VerificationMethod)
        
        var id: String {
            switch self {
            case .stringValue(let string):
                return string
            case .verificationMethod(let verificationMethod):
                return verificationMethod.id
            }
        }
    }
    
    public let id: String
    public let alsoKnownAs: String?
    public let controller: String?
    public let verificationMethod: [VerificationMethod]?
    public let authentication: [VerificationMethodMapping]?
    public let assertionMethod: [VerificationMethodMapping]?
    public let capabilityDelegation: [VerificationMethodMapping]?
    public let keyAgreement: [VerificationMethodMapping]?
    public let services: [AnyCodable]?
    
    public init(
        id: String,
        alsoKnownAs: String? = nil,
        controller: String? = nil,
        verificationMethod: [VerificationMethod]? = nil,
        authentication: [VerificationMethodMapping]? = nil,
        assertionMethod: [VerificationMethodMapping]? = nil,
        capabilityDelegation: [VerificationMethodMapping]? = nil,
        keyAgreement: [VerificationMethodMapping]? = nil,
        services: [AnyCodable]? = nil
    ) {
        self.id = id
        self.alsoKnownAs = alsoKnownAs
        self.controller = controller
        self.verificationMethod = verificationMethod
        self.authentication = authentication
        self.assertionMethod = assertionMethod
        self.capabilityDelegation = capabilityDelegation
        self.keyAgreement = keyAgreement
        self.services = services
    }
}

extension DIDDocument: Codable {}
extension DIDDocument.Service: Codable {}

extension DIDDocument.VerificationMethodMapping: Codable {
    // Codable conformance for EndpointElement
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .stringValue(value)
        } else {
            let mapValue = try container.decode(DIDDocument.VerificationMethod.self)
            self = .verificationMethod(mapValue)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .stringValue(let value):
            try container.encode(value)
        case .verificationMethod(let verificationMethod):
            try container.encode(verificationMethod)
        }
    }
}

extension DIDDocument.VerificationMethod: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case controller
        case type
        case publicKeyBase58
        case publicKeyMultibase
        case publicKeyJwk
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        controller = try container.decode(String.self, forKey: .controller)
        type = try container.decode(String.self, forKey: .type)
        if
            let base58 = try container.decodeIfPresent(String.self, forKey: .publicKeyBase58),
            let data = Data(base64URLEncoded: base58)
        {
            material = VerificationMaterial(
                format: .base58,
                value: data
            )
        } else if
            let jwk = try container.decodeIfPresent(JWK.self, forKey: .publicKeyJwk)
        {
            material = VerificationMaterial(
                format: .jwk,
                value: try JSONEncoder.DIDDocumentEncoder().encode(jwk)
            )
        } else if
            let multibase = try container.decodeIfPresent(String.self, forKey: .publicKeyMultibase),
            let data = Data(base64URLEncoded: multibase)
        {
            material = VerificationMaterial(
                format: .multibase,
                value: data
            )
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [
                    CodingKeys.publicKeyBase58,
                    CodingKeys.publicKeyJwk,
                    CodingKeys.publicKeyMultibase
                ], debugDescription: "A valid key type was not found"
            ))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(controller, forKey: .controller)
        try container.encode(type, forKey: .type)
        switch material.format {
        case .base58:
            try container.encode(String(data: material.value, encoding: .utf8), forKey: .publicKeyBase58)
        case .jwk:
            let jwk = try JSONDecoder().decode(JWK.self, from: material.value)
            try container.encode(jwk, forKey: .publicKeyJwk)
        case .multibase:
            try container.encode(String(data: material.value, encoding: .utf8), forKey: .publicKeyMultibase)
        }
    }
}

extension DIDDocument: Identifiable {}
extension DIDDocument.VerificationMethod: Identifiable {}
extension DIDDocument.Service: Identifiable {}

extension VerificationMaterialFormat {
    
    init(fromKey: String) throws {
        switch fromKey {
        case "publicKeyBase58":
            self = .base58
        case "publicKeyMultibase":
            self = .multibase
        case "publicKeyJwk":
            self = .jwk
        default:
            throw DIDCoreError.invalidMaterialForm(fromKey)
        }
    }
    
    var keyString: String {
        switch self {
        case .base58: return "publicKeyBase58"
        case .jwk: return "publicKeyMultibase"
        case .multibase: return "publicKeyJwk"
        }
    }
}

private extension VerificationMaterial {
    func getJWKValue(type: KnownVerificationMaterialType) throws -> JWK {
        let jwkConverted = try convertToJWK(type: type)
        let decoder = JSONDecoder()
        return try decoder.decode(JWK.self, from: jwkConverted.value)
    }
}
