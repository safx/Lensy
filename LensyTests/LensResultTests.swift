//
//  LensResultTests.swift
//  Lensy
//
//  Created by Safx Developer on 2016/02/13.
//  Copyright © 2016年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Lensy

class LensResultTests: XCTestCase {

    func testThenOK() {
        let r = LensResult<String>.OK("").then { v -> LensResult<Int> in
            return .OK(99)
        }
        
        if case let .OK(v) = r {
            XCTAssertEqual(v, 99)
        } else {
            XCTAssert(false)
        }
    }

    func testThenError() {
        let r = LensResult<String>.Error(.OptionalNone).then { v -> LensResult<Int> in
            return .OK(99)
        }

        if case let .Error(v) = r {
            XCTAssertEqual(v, LensErrorType.OptionalNone)
        } else {
            XCTAssert(false)
        }
    }
    
}
