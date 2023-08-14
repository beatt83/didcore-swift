//
//  Errors.swift
//  
//
//  Created by Gonçalo Frade on 13/08/2023.
//

import Foundation

enum DIDCoreError: LocalizedError {
    case somethingWentWrong
    case invalidJWKMaterialType(String)
    case invalidCodec
    case invalidMaterialForm(String)
    case unsupportedJWKKeyDecoding // Can only decode keys from X
    case invalidBase64URLKey
}
