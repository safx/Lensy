//
//  LensyTests.swift
//  LensyTests
//
//  Created by Safx Developer on 2016/02/12.
//  Copyright © 2016年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Lensy

class LensyTests: XCTestCase {

    func testEnumStruct() {
        let e = EnumTest(gender: .Female)
        let r1 = EnumTest.Lenses.gender.get(e)
        if case let .OK(v) = r1 {
            XCTAssertEqual(v, Gender.Female)
        } else {
            XCTAssert(false)
        }

        let r2 = EnumTest.Lenses.gender.set(e, .Unknown)
        if case let .OK(v) = r2 {
            XCTAssertEqual(v.gender, Gender.Unknown)
        } else {
            XCTAssert(false)
        }
    }
    
    func testEnumStruct2() {
        let e = EnumTest(gender: .Female)
        let r1 = EnumTest.$.gender.get(e)
        if case let .OK(v) = r1 {
            XCTAssertEqual(v, Gender.Female)
        } else {
            XCTAssert(false)
        }

        let r2 = EnumTest.$.gender.set(e, .Unknown)
        if case let .OK(v) = r2 {
            XCTAssertEqual(v.gender, Gender.Unknown)
        } else {
            XCTAssert(false)
        }
    }
    
}

// MARK: - Enum Test

public enum Gender {
    case Male
    case Female
    case Unknown
}

public struct EnumTest {
    public let gender: Gender

    struct Lenses {
        static let gender = Lens<EnumTest, Gender>(
            g: { $0.gender },
            s: { (this, newValue) in EnumTest(gender: newValue) }
        )
    }
    static var $: EnumTestLensHelper<EnumTest> {
        return EnumTestLensHelper<EnumTest>(lens: createIdentityLens())
    }
}

struct EnumTestLensHelper<Whole>: LensHelperType {
    typealias Part = EnumTest
    let lens: Lens<Whole, Part>
    var gender: LensHelper<Whole, Gender> {
        return LensHelper<Whole, Gender>(parent: self, lens: EnumTest.Lenses.gender)
    }
}
