//
//  GithubColorsTests.swift
//  GhUserCollectionTests
//
//  Created by Paulus Armada on 2024/09/07.
//

import XCTest
@testable import GhUserCollection

final class GithubColorsTests: XCTestCase {
    
    let subject = GithubColors()
    
    func test_unknownKeys() {
        XCTAssertNil(subject.hex(forKey: "does_not_exist"))
    }
    
    func test_keysWithoutColor() {
        ["lean", "cobol"].forEach {
            XCTAssertNil(subject.hex(forKey: $0))
        }
    }
    
    func test_knownKeys() {
        [
            ("ada", "#02f88c"),
            ("fortran", "#4d41b1"),
            ("json with comments", "#292929"),
            ("swift", "#F05138"),
            ("kotlin", "#A97BFF")
        ].forEach {
            XCTAssertEqual(subject.hex(forKey: $0.0), $0.1)
        }
    }
    
    func test_caseInsensitivity() {
        [
            ("ADA", "#02f88c"),
            ("foRTRan", "#4d41b1"),
            ("json WITH comments", "#292929"),
            ("sWIFT", "#F05138"),
            ("KOTLin", "#A97BFF")
        ].forEach {
            XCTAssertEqual(subject.hex(forKey: $0.0), $0.1)
        }
    }
}
