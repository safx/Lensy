//
//  TestStructs.swift
//  Lensy
//
//  Created by Safx Developer on 2016/02/13.
//  Copyright © 2016年 Safx Developers. All rights reserved.
//

import XCTest
@testable import Lensy


public struct Book {
    public let title: String
    public let authors: [Person]
    public let publisher: Company?

    struct Lenses {
        static let title = Lens<Book, String>(
            g: { $0.title },
            s: { (this, newValue) in Book(title: newValue, authors: this.authors, publisher: this.publisher) }
        )
        static let authors = Lens<Book, [Person]>(
            g: { $0.authors },
            s: { (this, newValue) in Book(title: this.title, authors: newValue, publisher: this.publisher) }
        )
        static let publisher = Lens<Book, Company?>(
            g: { $0.publisher },
            s: { (this, newValue) in Book(title: this.title, authors: this.authors, publisher: newValue) }
        )
    }
    static var $: BookLensHelper<Book> {
        return BookLensHelper<Book>(lens: createIdentityLens())
    }
}

struct BookLensHelper<Whole>: LensHelperType {
    typealias Part = Book
    let lens: Lens<Whole, Part>
    var title: LensHelper<Whole, String> {
        return LensHelper<Whole, String>(parent: self, lens: Book.Lenses.title)
    }
    var authors: ArrayLensHelper<Whole, Person, PersonLensHelper<Whole>> {
        return ArrayLensHelper<Whole, Person, PersonLensHelper<Whole>>(parent: self, lens: Book.Lenses.authors)
    }
    var publisher: OptionalLensHelper<Whole, Company, CompanyLensHelper<Whole>> {
        return OptionalLensHelper<Whole, Company, CompanyLensHelper<Whole>>(parent: self, lens: Book.Lenses.publisher)
    }
}


public struct Company {
    public let name: String?
    public let address: Address

    struct Lenses {
        static let name = Lens<Company, String?>(
            g: { $0.name },
            s: { (this, newValue) in Company(name: newValue, address: this.address) }
        )
        static let address = Lens<Company, Address>(
            g: { $0.address },
            s: { (this, newValue) in Company(name: this.name, address: newValue) }
        )
    }
    static var $: CompanyLensHelper<Company> {
        return CompanyLensHelper<Company>(lens: createIdentityLens())
    }
}

struct CompanyLensHelper<Whole>: LensHelperType {
    typealias Part = Company
    let lens: Lens<Whole, Part>
    var name: OptionalLensHelper<Whole, String, LensHelper<Whole, String>> {
        return OptionalLensHelper<Whole, String, LensHelper<Whole, String>>(parent: self, lens: Company.Lenses.name)
    }
    var address: AddressLensHelper<Whole> {
        return AddressLensHelper<Whole>(parent: self, lens: Company.Lenses.address)
    }
}


public struct Person {
    public let name: String
    public let address: Address
    public let ids: [Int]

    struct Lenses {
        static let name = Lens<Person, String>(
            g: { $0.name },
            s: { (this, newValue) in Person(name: newValue, address: this.address, ids: this.ids) }
        )
        static let address = Lens<Person, Address>(
            g: { $0.address },
            s: { (this, newValue) in Person(name: this.name, address: newValue, ids: this.ids) }
        )
        static let ids = Lens<Person, [Int]>(
            g: { $0.ids },
            s: { (this, newValue) in Person(name: this.name, address: this.address, ids: newValue) }
        )
    }
    static var $: PersonLensHelper<Person> {
        return PersonLensHelper<Person>(lens: createIdentityLens())
    }
}

struct PersonLensHelper<Whole>: LensHelperType {
    typealias Part = Person
    let lens: Lens<Whole, Part>
    var name: LensHelper<Whole, String> {
        return LensHelper<Whole, String>(parent: self, lens: Person.Lenses.name)
    }
    var address: AddressLensHelper<Whole> {
        return AddressLensHelper<Whole>(parent: self, lens: Person.Lenses.address)
    }
    var ids: ArrayLensHelper<Whole, Int, LensHelper<Whole, Int>> {
        return ArrayLensHelper<Whole, Int, LensHelper<Whole, Int>>(parent: self, lens: Person.Lenses.ids)
    }
}


public struct Address {
    public let city: String
    
    struct Lenses {
        static let city = Lens<Address, String>(
            g: { $0.city },
            s: { (this, newValue) in Address(city: newValue) }
        )
    }
    static var $: AddressLensHelper<Address> {
        return AddressLensHelper<Address>(lens: createIdentityLens())
    }
}

struct AddressLensHelper<Whole>: LensHelperType {
    typealias Part = Address
    let lens: Lens<Whole, Part>
    var city: LensHelper<Whole, String> {
        return LensHelper<Whole, String>(parent: self, lens: Address.Lenses.city)
    }
}

