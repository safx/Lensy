//
//  LensHelperTests.swift
//  Lensy
//
//  Created by Safx Developer on 2016/02/13.
//  Copyright © 2016年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Lensy

class LensHelperTests: XCTestCase {
    let person1 = Person(name: "Yamada", address: Address(city: "Tokyo"), ids: [])
    var person2 = Person(name: "Suzuki", address: Address(city: "Osaka"), ids: [123, 456])
    var person3 = Person(name: "Takeda", address: Address(city: "Okinawa"), ids: [789])
    var company1 = Company(name: "Bigfoot", address: Address(city: "Nagoya"))
    var company2 = Company(name: nil, address: Address(city: "Tiba"))
    var book1: Book!
    var book2: Book!
    var book3: Book!

    override func setUp() {
        book1 = Book(title: "Swift Book", authors: [person1, person2], publisher: company1)
        book2 = Book(title: "Objective-C Book", authors: [person3], publisher: company2)
        book3 = Book(title: "LLVM Book", authors: [person3], publisher: nil)
    }

    func testHelperGet() {
        let r1 = Person.$.address.city.get(person1)
        if case let .OK(v) = r1 {
            XCTAssertEqual(v, "Tokyo")
        } else {
            XCTAssert(false)
        }

        let r2 = Book.$.publisher.unwrap.address.city.get(book1)
        if case let .OK(v) = r2 {
            XCTAssertEqual(v, "Nagoya")
        } else {
            XCTAssert(false)
        }

        let r3 = Book.$.publisher.unwrap.address.city.get(book3)
        if case let .Error(v) = r3 {
            XCTAssertEqual(v, LensErrorType.OptionalNone)
        } else {
            XCTAssert(false)
        }

        let r4 = Book.$.authors[1].name.get(book1)
        if case let .OK(v) = r4 {
            XCTAssertEqual(v, "Suzuki")
        } else {
            XCTAssert(false)
        }

        let r5 = Book.$.authors[1].name.get(book2)
        if case let .Error(v) = r5 {
            XCTAssertEqual(v, LensErrorType.ArrayIndexOutOfBounds)
        } else {
            XCTAssert(false)
        }
    }

    func testHelperSet() {
        let r1 = Person.$.address.city.set(person1, "Sapporo")
        if case let .OK(v) = r1 {
            XCTAssertEqual(v.address.city, "Sapporo")
        } else {
            XCTAssert(false)
        }

        let r2 = Book.$.publisher.unwrap.address.city.set(book1, "Yokohama")
        if case let .OK(v) = r2 {
            XCTAssertEqual(v.publisher!.address.city, "Yokohama")
        } else {
            XCTAssert(false)
        }

        let r3 = Book.$.publisher.unwrap.address.city.set(book3, "Nara")
        if case let .Error(v) = r3 {
            XCTAssertEqual(v, LensErrorType.OptionalNone)
        } else {
            XCTAssert(false)
        }

        let r4 = Book.$.authors[1].name.set(book1, "Nakano")
        if case let .OK(v) = r4 {
            XCTAssertEqual(v.authors[1].name, "Nakano")
        } else {
            XCTAssert(false)
        }

        let r5 = Book.$.authors[1].name.set(book2, "Wada")
        if case let .Error(v) = r5 {
            XCTAssertEqual(v, LensErrorType.ArrayIndexOutOfBounds)
        } else {
            XCTAssert(false)
        }
    }

    func testHelperModify() {
        let r1 = Book.$.authors[1].ids.modify(book1) { $0 + [-16] }
        if case let .OK(v) = r1 {
            XCTAssertEqual(v.authors[1].ids, [123, 456, -16])
        } else {
            XCTAssert(false)
        }

        let r2 = Book.$.authors[1].ids.modify(book2) { $0 + [-16] }
        if case let .Error(v) = r2 {
            XCTAssertEqual(v, LensErrorType.ArrayIndexOutOfBounds)
        } else {
            XCTAssert(false)
        }
    }

    func testHelperModifyMap() {
        let r1 = Book.$.authors[1].ids.modifyMap(book1) { 0 - $0 }
        if case let .OK(v) = r1 {
            XCTAssertEqual(v.authors[1].ids, [-123, -456])
        } else {
            XCTAssert(false)
        }

        let r2 = Book.$.authors[1].ids.modifyMap(book2) { 0 - $0 }
        if case let .Error(v) = r2 {
            XCTAssertEqual(v, LensErrorType.ArrayIndexOutOfBounds)
        } else {
            XCTAssert(false)
        }
    }
}
