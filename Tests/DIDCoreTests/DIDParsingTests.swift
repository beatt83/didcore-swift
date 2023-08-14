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
}
