//
//  LensFailableTests.swift
//  Lensy
//
//  Created by Safx Developer on 2016/02/13.
//  Copyright © 2016年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Lensy

class LensFailableTests: XCTestCase {
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

    func testOptionalGet() {
        let c1 = Company.Lenses.name

        let r1 = c1.get(company1)
        if case let .OK(v) = r1 {
            XCTAssertEqual(v, "Bigfoot")
        } else {
            XCTAssert(false)
        }

        let r2 = c1.get(company2)
        if case let .OK(v) = r2 {
            XCTAssertEqual(v, nil)
        } else {
            XCTAssert(false)
        }

        let c2 = Company.Lenses.name.compose(OptionalUnwrapLens<String>())

        let r3 = c2.get(company1)
        if case let .OK(v) = r3 {
            XCTAssertEqual(v, "Bigfoot")
        } else {
            XCTAssert(false)
        }

        let r4 = c2.get(company2)
        if case let .Error(v) = r4 {
            XCTAssertEqual(v, LensErrorType.OptionalNone)
        } else {
            XCTAssert(false)
        }

        let c3 = Book.Lenses.publisher.compose(OptionalUnwrapLens<Company>()).compose(Company.Lenses.name).compose(OptionalUnwrapLens<String>())

        let r5 = c3.get(book1)
        if case let .OK(v) = r5 {
            XCTAssertEqual(v, "Bigfoot")
        } else {
            XCTAssert(false)
        }

        let r6 = c3.get(book2)
        if case let .Error(v) = r6 {
            XCTAssertEqual(v, LensErrorType.OptionalNone)
        } else {
            XCTAssert(false)
        }

        let r7 = c3.get(book3)
        if case let .Error(v) = r7 {
            XCTAssertEqual(v, LensErrorType.OptionalNone)
        } else {
            XCTAssert(false)
        }
    }

    func testOptionalSet() {
        let c1 = Company.Lenses.name

        let r1 = c1.set(company1, "Silver Goose")
        if case let .OK(v) = r1 {
            XCTAssertEqual(v.name, "Silver Goose")
            XCTAssertEqual(v.address.city, "Nagoya")
        } else {
            XCTAssert(false)
        }

        let r2 = c1.set(company2, "Silver Goose")
        if case let .OK(v) = r2 {
            XCTAssertEqual(v.name, "Silver Goose")
            XCTAssertEqual(v.address.city, "Tiba")
        } else {
            XCTAssert(false)
        }

        let c2 = Company.Lenses.name.compose(OptionalUnwrapLens<String>())

        let r3 = c2.set(company1, "Silver Goose")
        if case let .OK(v) = r3 {
            XCTAssertEqual(v.name, "Silver Goose")
            XCTAssertEqual(v.address.city, "Nagoya")
        } else {
            XCTAssert(false)
        }

        let r4 = c2.set(company2, "Silver Goose")
        if case let .Error(v) = r4 {
            XCTAssertEqual(v, LensErrorType.OptionalNone)
        } else {
            XCTAssert(false)
        }

        let c3 = Book.Lenses.publisher.compose(OptionalUnwrapLens<Company>()).compose(Company.Lenses.name).compose(OptionalUnwrapLens<String>())

        let r5 = c3.set(book1, "Gold Goose")
        if case let .OK(v) = r5 {
            XCTAssertEqual(v.title, "Swift Book")
            XCTAssertEqual(v.publisher!.name, "Gold Goose")
            XCTAssertEqual(v.authors[0].name, "Yamada")
            XCTAssertEqual(v.authors[1].name, "Suzuki")
        } else {
            XCTAssert(false)
        }

        let r6 = c3.set(book2, "Gold Goose")
        if case let .Error(v) = r6 {
            XCTAssertEqual(v, LensErrorType.OptionalNone)
        } else {
            XCTAssert(false)
        }

        let r7 = c3.set(book3, "Gold Goose")
        if case let .Error(v) = r7 {
            XCTAssertEqual(v, LensErrorType.OptionalNone)
        } else {
            XCTAssert(false)
        }
    }

    func testArrayGet() {
        let c0 = Book.Lenses.authors.compose(ArrayIndexLens<Person>(at: 0))
        let c1 = Book.Lenses.authors.compose(ArrayIndexLens<Person>(at: 1))
        let c2 = Book.Lenses.authors.compose(ArrayIndexLens<Person>(at: 2))

        let r10 = c0.get(book1)
        if case let .OK(v) = r10 {
            XCTAssertEqual(v.name, "Yamada")
            XCTAssertEqual(v.address.city, "Tokyo")
        } else {
            XCTAssert(false)
        }

        let r11 = c1.get(book1)
        if case let .OK(v) = r11 {
            XCTAssertEqual(v.name, "Suzuki")
            XCTAssertEqual(v.address.city, "Osaka")
        } else {
            XCTAssert(false)
        }

        let r12 = c2.get(book1)
        if case let .Error(v) = r12 {
            XCTAssertEqual(v, LensErrorType.ArrayIndexOutOfBounds)
        } else {
            XCTAssert(false)
        }

        let n0 = Book.Lenses.authors.compose(ArrayIndexLens<Person>(at: 0)).compose(Person.Lenses.name)
        let n1 = Book.Lenses.authors.compose(ArrayIndexLens<Person>(at: 1)).compose(Person.Lenses.name)
        let n2 = Book.Lenses.authors.compose(ArrayIndexLens<Person>(at: 2)).compose(Person.Lenses.name)

        let r20 = n0.get(book1)
        if case let .OK(v) = r20 {
            XCTAssertEqual(v, "Yamada")
        } else {
            XCTAssert(false)
        }

        let r21 = n1.get(book1)
        if case let .OK(v) = r21 {
            XCTAssertEqual(v, "Suzuki")
        } else {
            XCTAssert(false)
        }

        let r22 = n2.get(book1)
        if case let .Error(v) = r22 {
            XCTAssertEqual(v, LensErrorType.ArrayIndexOutOfBounds)
        } else {
            XCTAssert(false)
        }
    }

    func testArraySet() {
        let c0 = Book.Lenses.authors.compose(ArrayIndexLens<Person>(at: 0))
        let c1 = Book.Lenses.authors.compose(ArrayIndexLens<Person>(at: 1))
        let c2 = Book.Lenses.authors.compose(ArrayIndexLens<Person>(at: 2))

        let r10 = c0.set(book1, Person(name: "Morita", address: Address(city: "Saitama"), ids: [777]))
        if case let .OK(v) = r10 {
            XCTAssertEqual(v.authors[0].name, "Morita")
            XCTAssertEqual(v.authors[0].address.city, "Saitama")
            XCTAssertEqual(v.authors[0].ids, [777])

            XCTAssertEqual(v.title, "Swift Book")
            XCTAssertEqual(v.publisher!.name, "Bigfoot")
            XCTAssertEqual(v.authors[1].name, "Suzuki")
        } else {
            XCTAssert(false)
        }

        let r11 = c1.set(book1, Person(name: "Morita", address: Address(city: "Saitama"), ids: [777]))
        if case let .OK(v) = r11 {
            XCTAssertEqual(v.authors[1].name, "Morita")
            XCTAssertEqual(v.authors[1].address.city, "Saitama")
            XCTAssertEqual(v.authors[1].ids, [777])

            XCTAssertEqual(v.title, "Swift Book")
            XCTAssertEqual(v.publisher!.name, "Bigfoot")
            XCTAssertEqual(v.authors[0].name, "Yamada")
        } else {
            XCTAssert(false)
        }

        let r12 = c2.set(book1, Person(name: "Morita", address: Address(city: "Saitama"), ids: [777]))
        if case let .Error(v) = r12 {
            XCTAssertEqual(v, LensErrorType.ArrayIndexOutOfBounds)
        } else {
            XCTAssert(false)
        }

        let n0 = Book.Lenses.authors.compose(ArrayIndexLens<Person>(at: 0)).compose(Person.Lenses.name)
        let n1 = Book.Lenses.authors.compose(ArrayIndexLens<Person>(at: 1)).compose(Person.Lenses.name)
        let n2 = Book.Lenses.authors.compose(ArrayIndexLens<Person>(at: 2)).compose(Person.Lenses.name)

        let r20 = n0.set(book1, "Yamashita")
        if case let .OK(v) = r20 {
            XCTAssertEqual(v.authors[0].name, "Yamashita")
            XCTAssertEqual(v.authors[0].address.city, "Tokyo")
            XCTAssertEqual(v.authors[0].ids, [])

            XCTAssertEqual(v.title, "Swift Book")
            XCTAssertEqual(v.publisher!.name, "Bigfoot")
            XCTAssertEqual(v.authors[1].name, "Suzuki")
        } else {
            XCTAssert(false)
        }

        let r21 = n1.set(book1, "Yamashita")
        if case let .OK(v) = r21 {
            XCTAssertEqual(v.authors[1].name, "Yamashita")
            XCTAssertEqual(v.authors[1].address.city, "Osaka")
            XCTAssertEqual(v.authors[1].ids, [123, 456])

            XCTAssertEqual(v.title, "Swift Book")
            XCTAssertEqual(v.publisher!.name, "Bigfoot")
            XCTAssertEqual(v.authors[0].name, "Yamada")
        } else {
            XCTAssert(false)
        }

        let r22 = n2.set(book1, "Morita")
        if case let .Error(v) = r22 {
            XCTAssertEqual(v, LensErrorType.ArrayIndexOutOfBounds)
        } else {
            XCTAssert(false)
        }
    }


    func testTryGet1() {
        let c = Book.Lenses.publisher.compose(OptionalUnwrapLens<Company>()).compose(Company.Lenses.name).compose(OptionalUnwrapLens<String>())

        let expectation = expectationWithDescription("")

        do {
            let v = try c.tryGet(book1)
            XCTAssertEqual(v, "Bigfoot")
            expectation.fulfill()
        } catch {
        }

        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testTryGet2() {
        let c = Book.Lenses.publisher.compose(OptionalUnwrapLens<Company>()).compose(Company.Lenses.name).compose(OptionalUnwrapLens<String>())

        let expectation = expectationWithDescription("")

        do {
            _ = try c.tryGet(book2)
        } catch {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testTrySet1() {
        let c = Book.Lenses.publisher.compose(OptionalUnwrapLens<Company>()).compose(Company.Lenses.name).compose(OptionalUnwrapLens<String>())

        let expectation = expectationWithDescription("")

        do {
            let v = try c.trySet(book1, "Gold Experience")
            XCTAssertEqual(v.publisher!.name, "Gold Experience")

            XCTAssertEqual(v.title, "Swift Book")
            XCTAssertEqual(v.authors[0].name, "Yamada")
            XCTAssertEqual(v.authors[1].name, "Suzuki")
            expectation.fulfill()
        } catch {
        }

        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testTrySet2() {
        let c = Book.Lenses.publisher.compose(OptionalUnwrapLens<Company>()).compose(Company.Lenses.name).compose(OptionalUnwrapLens<String>())

        let expectation = expectationWithDescription("")

        do {
            _ = try c.trySet(book2, "Bad Experience")
        } catch {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(3) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }
}
