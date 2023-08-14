//
//  Multicodec.swift
//
//
//  Created by Gonçalo Frade on 11/08/2023.
//

import Foundation

public struct Multicodec {
    public enum Codec: Int {
        case X25519 = 0xEC
        case ED25519 = 0xED
    }
    
    public func toMulticodec(value: Data, codec: Codec) -> Data {
        let prefix = codec.rawValue
        var data = Data(putUVarInt(UInt64(prefix)))
        data.append(value)
        return data
    }

    public func fromMulticodec(value: Data) throws -> (codec: Codec, data: Data) {
        let (prefix, bytesRead) = uVarInt(Array(value))
        guard let codec = Codec(rawValue: Int(prefix)) else {
            throw DIDCoreError.invalidCodec
        }
        return (codec, value.dropFirst(bytesRead))
    }

    private func getCodec(prefix: Int) -> Codec? {
        return Codec(rawValue: prefix)
    }
}

extension Multicodec {
    
    public func toMulticodec(value: Data, keyType: KnownVerificationMaterialType) -> Data {
        toMulticodec(value: value, codec: getCodec(keyType: keyType))
    }
    
    private func getCodec(keyType: KnownVerificationMaterialType) -> Codec {
        switch keyType {
        case .authentication:
            return .ED25519
        case .agreement:
            return .X25519
        }
    }
}
