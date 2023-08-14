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
        let endpoint = DIDDocument.Service.ServiceEndpoint.string("testEndpoint")
        let encodedData = try! JSONEncoder().encode(endpoint)
        print(String(data: encodedData, encoding: .utf8)!)
        let decodedEndpoint = try! JSONDecoder().decode(DIDDocument.Service.ServiceEndpoint.self, from: encodedData)
        
        if case let .string(value) = decodedEndpoint {
            XCTAssertEqual(value, "testEndpoint")
        } else {
            XCTFail("Decoded ServiceEndpoint is not of type .string")
        }
    }
    
    func testSetEndpointEncodingDecoding() {
        let endpointSet = ["test1", "test2"]
        let endpoint = DIDDocument.Service.ServiceEndpoint.set(endpointSet)
        let encodedData = try! JSONEncoder().encode(endpoint)
        let decodedEndpoint = try! JSONDecoder().decode(DIDDocument.Service.ServiceEndpoint.self, from: encodedData)
        
        if case let .set(value) = decodedEndpoint {
            XCTAssertEqual(value, endpointSet)
        } else {
            XCTFail("Decoded ServiceEndpoint is not of type .set")
        }
    }
    
    func testMapEndpointEncodingDecoding() {
        let endpointMap = ["key1": "value1", "key2": "value2"]
        let endpoint = DIDDocument.Service.ServiceEndpoint.map(endpointMap)
        let encodedData = try! JSONEncoder().encode(endpoint)
        let decodedEndpoint = try! JSONDecoder().decode(DIDDocument.Service.ServiceEndpoint.self, from: encodedData)
        
        if case let .map(value) = decodedEndpoint {
            XCTAssertEqual(value, endpointMap)
        } else {
            XCTFail("Decoded ServiceEndpoint is not of type .map")
        }
    }
    
    func testComboEndpointEncodingDecoding() {
        let endpointCombo = [
            DIDDocument.Service.ServiceEndpoint.EndpointElement.stringValue("testValue"),
            DIDDocument.Service.ServiceEndpoint.EndpointElement.mapValue(["key": "value"])
        ]
        let endpoint = DIDDocument.Service.ServiceEndpoint.combo(endpointCombo)
        let encodedData = try! JSONEncoder().encode(endpoint)
        let decodedEndpoint = try! JSONDecoder().decode(DIDDocument.Service.ServiceEndpoint.self, from: encodedData)
        
        if case let .combo(value) = decodedEndpoint {
            XCTAssertEqual(value.count, endpointCombo.count)
            if case let .stringValue(stringValue) = value[0] {
                XCTAssertEqual(stringValue, "testValue")
            } else {
                XCTFail("First element of decoded combo is not of type .stringValue")
            }
            
            if case let .mapValue(mapValue) = value[1], let mapItem = mapValue["key"] {
                XCTAssertEqual(mapItem, "value")
            } else {
                XCTFail("Second element of decoded combo is not of type .mapValue")
            }
        } else {
            XCTFail("Decoded ServiceEndpoint is not of type .combo")
        }
    }
}
