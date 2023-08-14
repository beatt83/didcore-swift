//
//  DIDUrlParsingTests.swift
//  
//
//  Created by Gonçalo Frade on 14/08/2023.
//
@testable import DIDCore
import XCTest

final class DIDUrlParsingTests: XCTestCase {

    func testDIDUrlParsing() {
        let example1 = "did:example:123456789abcdefghi"
        let didUrl1 = DIDUrl(from: example1)
        XCTAssertNotNil(didUrl1)
        XCTAssertEqual(didUrl1?.did.method, "example")
        XCTAssertEqual(didUrl1?.did.methodId, "123456789abcdefghi")
        XCTAssertTrue(didUrl1?.queries.isEmpty ?? false)
        XCTAssertNil(didUrl1?.path)
        XCTAssertNil(didUrl1?.fragment)
        
        let example2 = "did:example:123456/path"
        let didUrl2 = DIDUrl(from: example2)
        XCTAssertNotNil(didUrl2)
        XCTAssertEqual(didUrl2?.did.method, "example")
        XCTAssertEqual(didUrl2?.did.methodId, "123456")
        XCTAssertTrue(didUrl2?.queries.isEmpty ?? false)
        XCTAssertEqual(didUrl2?.path, "/path")
        XCTAssertNil(didUrl2?.fragment)
        
        let example3 = "did:example:123456?versionId=1"
        let didUrl3 = DIDUrl(from: example3)
        XCTAssertNotNil(didUrl3)
        XCTAssertEqual(didUrl3?.did.method, "example")
        XCTAssertEqual(didUrl3?.did.methodId, "123456")
        XCTAssertEqual(didUrl3?.queries["versionId"], "1")
        XCTAssertNil(didUrl3?.path)
        XCTAssertNil(didUrl3?.fragment)
        
        let example4 = "did:example:123#public-key-0"
        let didUrl4 = DIDUrl(from: example4)
        XCTAssertNotNil(didUrl4)
        XCTAssertEqual(didUrl4?.did.method, "example")
        XCTAssertEqual(didUrl4?.did.methodId, "123")
        XCTAssertTrue(didUrl4?.queries.isEmpty ?? false)
        XCTAssertNil(didUrl4?.path)
        XCTAssertEqual(didUrl4?.fragment, "public-key-0")
        
        let example5 = "did:example:123?service=agent&relativeRef=/credentials#degree"
        let didUrl5 = DIDUrl(from: example5)
        XCTAssertNotNil(didUrl5)
        XCTAssertEqual(didUrl5?.did.method, "example")
        XCTAssertEqual(didUrl5?.did.methodId, "123")
        XCTAssertEqual(didUrl5?.queries["service"], "agent")
        XCTAssertEqual(didUrl5?.queries["relativeRef"], "/credentials")
        XCTAssertNil(didUrl5?.path)
        XCTAssertEqual(didUrl5?.fragment, "degree")
    }
}
