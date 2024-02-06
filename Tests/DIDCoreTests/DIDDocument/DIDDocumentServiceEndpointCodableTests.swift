//
//  DIDDocumentServiceEndpointCodableTests.swift
//  
//
//  Created by Gonçalo Frade on 14/08/2023.
//

@testable import DIDCore
import XCTest

class ServiceEndpointTests: XCTestCase {
    
    func testStringEndpointEncodingDecoding() {
        let endpoint = AnyCodable("testEndpoint")
        let encodedData = try! JSONEncoder().encode(endpoint)
        print(String(data: encodedData, encoding: .utf8)!)
        let decodedEndpoint = try! JSONDecoder().decode(AnyCodable.self, from: encodedData)
        
        XCTAssertEqual(decodedEndpoint.get(), "testEndpoint")
    }
    
    func testSetEndpointEncodingDecoding() {
        let endpointSet = ["test1", "test2"]
        let endpoint = AnyCodable(endpointSet)
        let encodedData = try! JSONEncoder().encode(endpoint)
        let decodedEndpoint = try! JSONDecoder().decode(AnyCodable.self, from: encodedData)
        
        XCTAssertEqual(decodedEndpoint.get(), endpointSet)
    }
    
    func testMapEndpointEncodingDecoding() {
        let endpointMap = ["key1": "value1", "key2": "value2"]
        let endpoint = AnyCodable(endpointMap)
        let encodedData = try! JSONEncoder().encode(endpoint)
        let decodedEndpoint = try! JSONDecoder().decode(AnyCodable.self, from: encodedData)
        
        XCTAssertEqual(decodedEndpoint.get(), endpointMap)
    }
    
    func testComboEndpointEncodingDecoding() {
        let endpointCombo = [
            "testValue",
            ["key": "value"]
        ] as [any Equatable]
        
        let endpoint = AnyCodable(endpointCombo)
        let encodedData = try! JSONEncoder().encode(endpoint)
        let decodedEndpoint = try! JSONDecoder().decode(AnyCodable.self, from: encodedData)
        let value = decodedEndpoint.get() as? [Any]
        
        XCTAssertEqual(value?.first as? String, "testValue")
        XCTAssertEqual(value?.last as? [String: String], ["key": "value"])
    }
}
