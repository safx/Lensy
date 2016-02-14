//
//  Lensy.swift
//  Lensy
//
//  Created by Safx Developer on 2016/02/12.
//  Copyright © 2016 Safx Developers. All rights reserved.
//


// MARK: - Lenses API

protocol LensType {
    typealias Whole
    typealias Part
    var get: Whole -> LensResult<Part> { get }
    var set: (Whole, Part) -> LensResult<Whole> { get }
}

struct Lens<Whole, Part>: LensType {
    let get: Whole -> LensResult<Part>
    let set: (Whole, Part) -> LensResult<Whole>
}

struct OptionalUnwrapLens<Element>: LensType {
    typealias Whole = Element?
    typealias Part = Element
    let get: Whole -> LensResult<Part>
    let set: (Whole, Part) -> LensResult<Whole>
}

struct ArrayIndexLens<Element>: LensType {
    typealias Whole = [Element]
    typealias Part = Element
    let get: Whole -> LensResult<Part>
    let set: (Whole, Part) -> LensResult<Whole>
}

extension LensType {
    func compose<Subpart, L: LensType where Self.Part == L.Whole, L.Part == Subpart>(other: L) -> Lens<Whole, Subpart> {
        return Lens<Whole, Subpart>(
            get: { (object: Whole) -> LensResult<Subpart> in
                return self.get(object)
                    .then(other.get)
            },
            set: { (object: Whole, newValue: Subpart) -> LensResult<Whole> in
                return self.get(object)
                    .then { other.set($0, newValue) }
                    .then { self.set(object, $0) }
            }
        )
    }

    func modify(object: Whole, @noescape _ closure: Part -> Part) -> LensResult<Whole> {
        return get(object)
            .then { self.set(object, closure($0)) }
    }

    func tryGet(object: Whole) throws -> Part {
        switch get(object) {
        case .OK(let v):
            return v
        case .Error(let e):
            throw e
        }
    }

    func trySet(object: Whole, _ newValue: Part) throws -> Whole {
        switch set(object, newValue) {
        case .OK(let v):
            return v
        case .Error(let e):
            throw e
        }
    }
}

extension Lens {
    init(g: Whole -> Part, s: (Whole, Part) -> Whole) {
        get = { .OK(g($0)) }
        set = { .OK(s($0, $1)) }
    }
}

extension OptionalUnwrapLens {
    init() {
        get = { optional in
            guard let v = optional else {
                return .Error(LensErrorType.OptionalNone)
            }
            return .OK(v)
        }
        set = { optional, newValue in
            guard var v = optional else {
                return .Error(LensErrorType.OptionalNone)
            }
            v = newValue
            return .OK(v)
        }
    }
}

extension ArrayIndexLens {
    init(at idx: Int) {
        get = { array in
            guard 0..<array.count ~= idx else {
                return .Error(LensErrorType.ArrayIndexOutOfBounds)
            }
            return .OK(array[idx])
        }
        set = { array, newValue in
            guard 0..<array.count ~= idx else {
                return .Error(LensErrorType.ArrayIndexOutOfBounds)
            }
            var arr = array
            arr[idx] = newValue
            return .OK(arr)
        }
    }
}


// MARK: - Lens Utility Function

func createIdentityLens<Whole>() -> Lens<Whole, Whole> {
    return Lens<Whole, Whole>(
        g: { $0 },
        s: { $1 }
    )
}

// MARK: - Result

enum LensResult<Element> {
    case OK(Element)
    case Error(LensErrorType)
}

extension LensResult {
    func then<T>(@noescape closure: Element -> LensResult<T>) -> LensResult<T> {
        switch self {
        case .OK(let v):
            return closure(v)
        case .Error(let e):
            return .Error(e)
        }
    }
}

// MARK: - Error

enum LensErrorType: ErrorType {
    case OptionalNone
    case ArrayIndexOutOfBounds
}


// MARK: - Lens Helper

protocol LensHelperType {
    typealias Whole
    typealias Part

    init(lens: Lens<Whole, Part>)
    var lens: Lens<Whole, Part> { get }
}

protocol HasSubLensHelper {
    typealias SubLensHelper
}

struct LensHelper<Whole, Part>: LensHelperType {
    let lens: Lens<Whole, Part>
}

struct ArrayLensHelper<Whole, Element, Sub>: LensHelperType, HasSubLensHelper {
    typealias Part = [Element]
    typealias SubLensHelper = Sub
    let lens: Lens<Whole, Part>
}

struct OptionalLensHelper<Whole, Element, Sub>: LensHelperType, HasSubLensHelper {
    typealias Part = Element?
    typealias SubLensHelper = Sub
    let lens: Lens<Whole, Part>
}

extension LensHelperType {
    init<Parent: LensHelperType where Parent.Whole == Whole>(parent: Parent, lens: Lens<Parent.Part, Part>) {
        self.init(lens: parent.lens.compose(lens))
    }

    func get(object: Whole) -> LensResult<Part> {
        return lens.get(object)
    }

    func set(object: Whole, _ newValue: Part) -> LensResult<Whole> {
        return lens.set(object, newValue)
    }

    func modify(object: Whole, @noescape closure: Part -> Part) -> LensResult<Whole> {
        return lens.modify(object, closure)
    }
}

extension ArrayLensHelper where Sub: LensHelperType, Sub.Whole == Whole, Sub.Part == Element {
    subscript(idx: Int) -> SubLensHelper {
        return SubLensHelper(lens: lens.compose(ArrayIndexLens<Element>(at: idx)))
    }

    func modifyMap(object: Whole, @noescape closure: Element -> Element) -> LensResult<Whole> {
        return lens.modify(object) { $0.map(closure) }
    }
}

extension OptionalLensHelper where Sub: LensHelperType, Sub.Whole == Whole, Sub.Part == Element {
    var unwrap: SubLensHelper {
        return SubLensHelper(lens: lens.compose(OptionalUnwrapLens<Element>()))
    }
}
