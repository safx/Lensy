//
//  LensTests.swift
//  Lensy
//
//  Created by Safx Developer on 2016/02/13.
//  Copyright © 2016年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Lensy

class LensBaseTests: XCTestCase {
    let person = Person(name: "Yamamoto", address: Address(city: "Tokyo"), ids: [9, 11, 42])

    func testGet() {
        let r1 = Person.Lenses.name.get(person)
        if case let .OK(v) = r1 {
            XCTAssertEqual(v, "Yamamoto")
        } else {
            XCTAssert(false)
        }

        let r2 = Address.Lenses.city.get(person.address)
        if case let .OK(v) = r2 {
            XCTAssertEqual(v, "Tokyo")
        } else {
            XCTAssert(false)
        }

        let r3 = Person.Lenses.ids.get(person)
        if case let .OK(v) = r3 {
            XCTAssertEqual(v, [9, 11, 42])
        } else {
            XCTAssert(false)
        }
    }

    func testSet() {
        let r1 = Person.Lenses.name.set(person, "Sakamoto")
        if case let .OK(v) = r1 {
            XCTAssertEqual(v.name, "Sakamoto")
            XCTAssertEqual(v.address.city, "Tokyo")
            XCTAssertEqual(v.ids, [9, 11, 42])
        } else {
            XCTAssert(false)
        }

        let r2 = Address.Lenses.city.set(person.address, "Osaka")
        if case let .OK(v) = r2 {
            XCTAssertEqual(v.city, "Osaka")
        } else {
            XCTAssert(false)
        }

        let r3 = Person.Lenses.ids.set(person, [99, 100])
        if case let .OK(v) = r3 {
            XCTAssertEqual(v.name, "Yamamoto")
            XCTAssertEqual(v.address.city, "Tokyo")
            XCTAssertEqual(v.ids, [99, 100])
        } else {
            XCTAssert(false)
        }
    }

    func testModify() {
        let r1 = Person.Lenses.name.modify(person) { "[[\($0)]]" }
        if case let .OK(v) = r1 {
            XCTAssertEqual(v.name, "[[Yamamoto]]")
            XCTAssertEqual(v.address.city, "Tokyo")
            XCTAssertEqual(v.ids, [9, 11, 42])
        } else {
            XCTAssert(false)
        }

        let r2 = Address.Lenses.city.modify(person.address) { $0.uppercaseString }
        if case let .OK(v) = r2 {
            XCTAssertEqual(v.city, "TOKYO")
        } else {
            XCTAssert(false)
        }

        let r3 = Person.Lenses.ids.modify(person) { $0.map{ 0 - $0 } }
        if case let .OK(v) = r3 {
            XCTAssertEqual(v.name, "Yamamoto")
            XCTAssertEqual(v.address.city, "Tokyo")
            XCTAssertEqual(v.ids, [-9, -11, -42])
        } else {
            XCTAssert(false)
        }
    }

    func testComposedGet() {
        let r1 = Person.Lenses.address.compose(Address.Lenses.city).get(person)
        if case let .OK(v) = r1 {
            XCTAssertEqual(v, "Tokyo")
        } else {
            XCTAssert(false)
        }
    }

    func testComposedSet() {
        let r1 = Person.Lenses.address.compose(Address.Lenses.city).set(person, "Nagoya")
        if case let .OK(v) = r1 {
            XCTAssertEqual(v.name, "Yamamoto")
            XCTAssertEqual(v.address.city, "Nagoya")
            XCTAssertEqual(v.ids, [9, 11, 42])
        } else {
            XCTAssert(false)
        }
    }

    func testComposedModify() {
        let r1 = Person.Lenses.address.compose(Address.Lenses.city).modify(person) { String($0.characters.reverse()) }
        if case let .OK(v) = r1 {
            XCTAssertEqual(v.name, "Yamamoto")
            XCTAssertEqual(v.address.city, "oykoT")
            XCTAssertEqual(v.ids, [9, 11, 42])
        } else {
            XCTAssert(false)
        }
    }
}

