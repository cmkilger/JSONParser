//
//  JSONFindPathTests.swift
//  JSONParsingTests
//
//  Created by Cory Kilger on 6/27/22.
//  Copyright © 2022 Cory Kilger. All rights reserved.
//

import XCTest
import JSONParsing

extension JSONPosition: Equatable {
    public static func == (lhs: JSONPosition, rhs: JSONPosition) -> Bool {
        lhs.byte == rhs.byte && lhs.line == rhs.line && lhs.codepoint == rhs.codepoint
    }
}

private extension JSONPath {
    static func paths(_ data: Data, _ style1: String, style2: String) throws -> [JSONPath] {
        [
            try XCTUnwrap(JSONPath(from: style1)),
            try XCTUnwrap(JSONPath(from: style2, in: data))
        ]
    }
}

final class JSONFindPathTests: XCTestCase {
    func testRootObject() throws {
        let data = "{}".data(using: .utf8)!
        for path in try JSONPath.paths(data, "", style2: "/") {
            XCTAssertEqual(try JSONFindPath.position(for: path, in: data), JSONPosition(byte: 0, line: 0, codepoint: 0))
        }
    }
    
    func testRootArray() throws {
        let data = "[]".data(using: .utf8)!
        for path in try JSONPath.paths(data, "", style2: "/") {
            XCTAssertEqual(try JSONFindPath.position(for: path, in: data), JSONPosition(byte: 0, line: 0, codepoint: 0))
        }
    }
    
    func testFirstKeyInObject() throws {
        let data = """
        {
            "first_name": "John",
            "last_name": "Smith"
        }
        """.data(using: .utf8)!
        for path in try JSONPath.paths(data, "first_name", style2: "/first_name") {
            XCTAssertEqual(try JSONFindPath.position(for: path, in: data), JSONPosition(byte: 20, line: 1, codepoint: 18))
        }
    }
    
    func testSecondKeyInObject() throws {
        let data = """
        {
            "first_name": "John",
            "last_name": "Smith"
        }
        """.data(using: .utf8)!
        for path in try JSONPath.paths(data, "last_name", style2: "/last_name") {
            XCTAssertEqual(try JSONFindPath.position(for: path, in: data), JSONPosition(byte: 45, line: 2, codepoint: 17))
        }
    }
    
    func testFirstIndexInArray() throws {
        let data = """
        [
            {
                "first_name": "John",
                "last_name": "Smith"
            },
            {
                "first_name": "Jane",
                "last_name": "Jones"
            }
        ]
        """.data(using: .utf8)!
        for path in try JSONPath.paths(data, "[0]", style2: "/0") {
            XCTAssertEqual(try JSONFindPath.position(for: path, in: data), JSONPosition(byte: 6, line: 1, codepoint: 4))
        }
    }
    
    func testSecondIndexInArray() throws {
        let data = """
        [
            {
                "first_name": "John",
                "last_name": "Smith"
            },
            {
                "first_name": "Jane",
                "last_name": "Jones"
            }
        ]
        """.data(using: .utf8)!
        for path in try JSONPath.paths(data, "[1]", style2: "/1") {
            XCTAssertEqual(try JSONFindPath.position(for: path, in: data), JSONPosition(byte: 78, line: 5, codepoint: 4))
        }
    }
    
    func testPeopleFirstIndexFirstKey() throws {
        let data = """
        {
            "people": [
                {
                    "first_name": "John",
                    "last_name": "Smith"
                },
                {
                    "first_name": "Jane",
                    "last_name": "Jones"
                }
            ]
        }
        """.data(using: .utf8)!
        for path in try JSONPath.paths(data, "people[0].first_name", style2: "/people/0/first_name") {
            XCTAssertEqual(try JSONFindPath.position(for: path, in: data), JSONPosition(byte: 54, line: 3, codepoint: 26))
        }
    }
    
    func testPeopleFirstIndexSecondKey() throws {
        let data = """
        {
            "people": [
                {
                    "first_name": "John",
                    "last_name": "Smith"
                },
                {
                    "first_name": "Jane",
                    "last_name": "Jones"
                }
            ]
        }
        """.data(using: .utf8)!
        for path in try JSONPath.paths(data, "people[0].last_name", style2: "/people/0/last_name") {
            XCTAssertEqual(try JSONFindPath.position(for: path, in: data), JSONPosition(byte: 87, line: 4, codepoint: 25))
        }
    }
    
    func testPeopleSecondIndexFirstKey() throws {
        let data = """
        {
            "people": [
                {
                    "first_name": "John",
                    "last_name": "Smith"
                },
                {
                    "first_name": "Jane",
                    "last_name": "Jones"
                }
            ]
        }
        """.data(using: .utf8)!
        for path in try JSONPath.paths(data, "people[1].first_name", style2: "/people/1/first_name") {
            XCTAssertEqual(try JSONFindPath.position(for: path, in: data), JSONPosition(byte: 142, line: 7, codepoint: 26))
        }
    }
    
    func testPeopleSecondIndexSecondKey() throws {
        let data = """
        {
            "people": [
                {
                    "first_name": "John",
                    "last_name": "Smith"
                },
                {
                    "first_name": "Jane",
                    "last_name": "Jones"
                }
            ]
        }
        """.data(using: .utf8)!
        for path in try JSONPath.paths(data, "people[1].last_name", style2: "/people/1/last_name") {
            XCTAssertEqual(try JSONFindPath.position(for: path, in: data), JSONPosition(byte: 175, line: 8, codepoint: 25))
        }
    }
}
