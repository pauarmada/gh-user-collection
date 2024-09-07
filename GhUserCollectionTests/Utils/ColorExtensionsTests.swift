//
//  ColorExtensionsTests.swift
//  GhUserCollectionTests
//
//  Created by Paulus Armada on 2024/09/07.
//

import XCTest
@testable import GhUserCollection

final class ColorExtensionsTests: XCTestCase {
    
    func test_hexConversionCases() {
        [
            ("#FFFFFF", 1.0, 1.0, 1.0, 1.0),
            ("#000000", 0.0, 0.0, 0.0, 1.0),
            ("#7F7F7F", 0.5, 0.5, 0.5, 1.0),
            ("#00FFFFFF", 1.0, 1.0, 1.0, 0.0),
            ("#7F000000", 0.0, 0.0, 0.0, 0.5),
            ("#FF7F7F7F", 0.5, 0.5, 0.5, 1.0),
            
            ("FFFFFF", 1.0, 1.0, 1.0, 1.0),
            ("000000", 0.0, 0.0, 0.0, 1.0),
            ("7F7F7F", 0.5, 0.5, 0.5, 1.0),
            ("00FFFFFF", 1.0, 1.0, 1.0, 0.0),
            ("7F000000", 0.0, 0.0, 0.0, 0.5),
            ("FF7F7F7F", 0.5, 0.5, 0.5, 1.0),
            
            ("#ffffff", 1.0, 1.0, 1.0, 1.0),
            ("#000000", 0.0, 0.0, 0.0, 1.0),
            ("#7f7f7f", 0.5, 0.5, 0.5, 1.0),
            ("#00ffffff", 1.0, 1.0, 1.0, 0.0),
            ("#7f000000", 0.0, 0.0, 0.0, 0.5),
            ("#ff7f7f7f", 0.5, 0.5, 0.5, 1.0)
        ].forEach {
            guard let hexColor = HexColor(hex: $0.0) else {
                XCTFail()
                return
            }
            XCTAssertEqual(hexColor.red, CGFloat($0.1), accuracy: 0.05)
            XCTAssertEqual(hexColor.green, CGFloat($0.2), accuracy: 0.05)
            XCTAssertEqual(hexColor.blue, CGFloat($0.3), accuracy: 0.05)
            XCTAssertEqual(hexColor.alpha, CGFloat($0.4), accuracy: 0.05)
        }
    }
}
