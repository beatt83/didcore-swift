import XCTest
@testable import DIDCore

final class did_coreTests: XCTestCase {
    
    let validDIDs = [
        "did:example:123456789abcdefghi",
        "did:blockchain:abcd.efgh-ijk%20lmn",
        "did:test:1a2b3c",
        "did:foo:bar.baz-qux"
    ]

    let invalidDIDs = [
        "didexample:123456789abcdefghi",
        "did:example123456789abcdefghi",
        "DID:EXAMPLE:123456789abcdefghi",
        "did:example::123456789abcdefghi",
        "did::123456789abcdefghi",
        ":example:123456789abcdefghi"
    ]
    
    func testValidDIDParses() throws {
        validDIDs.forEach {
            XCTAssertNotNil(DID(from: $0))
        }
    }
    
    func testInvalidDIDParses() throws {
        invalidDIDs.forEach {
            XCTAssertNil(DID(from: $0))
        }
    }
    
    func testDIDString() throws {
        validDIDs.forEach {
            let did = DID(from: $0)!
            XCTAssertEqual($0, did.description)
        }
    }
    
    func testDIDDocumentCodable() throws {
        let didDocumentJson = "{\"@context\":[\"https://www.w3.org/ns/did/v1\",\"https://w3id.org/security/suites/jws-2020/v1\"],\"id\":\"did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445\",\"controller\":\"did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445\",\"verificationMethod\":[{\"id\":\"did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445#ed25519-assertionMethod\",\"type\":\"JsonWebKey2020\",\"controller\":\"did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445\",\"publicKeyJwk\":{\"crv\":\"Ed25519\",\"x\":\"oUPBTdXeX7Hecyvpb2ny4NGpR5xhuqBIY_xlW0en7eM\",\"kty\":\"OKP\"}},{\"id\":\"did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445#my-key-authentication\",\"type\":\"JsonWebKey2020\",\"controller\":\"did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445\",\"publicKeyJwk\":{\"crv\":\"Ed25519\",\"x\":\"pLF3PBcpcGwNbHZysEkshheRewv5qMIklYxRyOp3F84\",\"kty\":\"OKP\"}},{\"id\":\"did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445#secp256k1-assertionMethod\",\"type\":\"JsonWebKey2020\",\"controller\":\"did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445\",\"publicKeyJwk\":{\"crv\":\"secp256k1\",\"x\":\"kcsecQ0ODsHGe275oy4tFS2uQcyOG2kmTHf833Q0kjU\",\"y\":\"vvgm5JjVzV3qgrjMgUZZmif478ANz-WoeVXIDI-xr5Q\",\"kty\":\"EC\"}}],\"authentication\":[\"did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445#my-key-authentication\"],\"assertionMethod\":[\"did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445#ed25519-assertionMethod\",\"did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445#secp256k1-assertionMethod\"],\"keyAgreement\":[],\"capabilityInvocation\":[],\"capabilityDelegation\":[],\"service\":[]}"

        
        let diddocument = try JSONDecoder().decode(DIDDocument.self, from: didDocumentJson.data(using: .utf8)!)
        
        XCTAssertEqual(diddocument.authentication?.first?.id, "did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445#my-key-authentication")
        XCTAssertEqual(diddocument.assertionMethod?.first?.id, "did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445#ed25519-assertionMethod")
        XCTAssertEqual(diddocument.verificationMethod?.count, 3)
        XCTAssertEqual(diddocument.controller, "did:prism:9e2377fd10ff9a90fe69b2af195512179b23e7b23a4a860ebb9bd51e04f59445")
    }
}
