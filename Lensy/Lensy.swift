//
//  Lensy.swift
//  Lensy
//
//  Created by Safx Developer on 2016/02/12.
//  Copyright © 2016 Safx Developers. All rights reserved.
//


// MARK: - Lenses API

public protocol LensType {
    associatedtype Whole
    associatedtype Part
    var get: Whole -> LensResult<Part> { get }
    var set: (Whole, Part) -> LensResult<Whole> { get }
}

public struct Lens<Whole, Part>: LensType {
    public let get: Whole -> LensResult<Part>
    public let set: (Whole, Part) -> LensResult<Whole>
}

public struct OptionalUnwrapLens<Element>: LensType {
    public typealias Whole = Element?
    public typealias Part = Element
    public let get: Whole -> LensResult<Part>
    public let set: (Whole, Part) -> LensResult<Whole>
}

public struct ArrayIndexLens<Element>: LensType {
    public typealias Whole = [Element]
    public typealias Part = Element
    public let get: Whole -> LensResult<Part>
    public let set: (Whole, Part) -> LensResult<Whole>
}

public extension LensType {
    public func compose<Subpart, L: LensType where Self.Part == L.Whole, L.Part == Subpart>(other: L) -> Lens<Whole, Subpart> {
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

    public func modify(object: Whole, @noescape _ closure: Part -> Part) -> LensResult<Whole> {
        return get(object)
            .then { self.set(object, closure($0)) }
    }

    public func tryGet(object: Whole) throws -> Part {
        switch get(object) {
        case .OK(let v):
            return v
        case .Error(let e):
            throw e
        }
    }

    public func trySet(object: Whole, _ newValue: Part) throws -> Whole {
        switch set(object, newValue) {
        case .OK(let v):
            return v
        case .Error(let e):
            throw e
        }
    }
}

extension Lens {
    public init(g: Whole -> Part, s: (Whole, Part) -> Whole) {
        get = { .OK(g($0)) }
        set = { .OK(s($0, $1)) }
    }
}

extension OptionalUnwrapLens {
    public init() {
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
    public init(at idx: Int) {
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

public func createIdentityLens<Whole>() -> Lens<Whole, Whole> {
    return Lens<Whole, Whole>(
        g: { $0 },
        s: { $1 }
    )
}

// MARK: - Result

public enum LensResult<Element> {
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

public enum LensErrorType: ErrorType {
    case OptionalNone
    case ArrayIndexOutOfBounds
}


// MARK: - Lens Helper

public protocol LensHelperType {
    associatedtype Whole
    associatedtype Part

    init(lens: Lens<Whole, Part>)
    var lens: Lens<Whole, Part> { get }
}

public protocol HasSubLensHelper {
    associatedtype SubLensHelper
}

public struct LensHelper<Whole, Part>: LensHelperType {
    public let lens: Lens<Whole, Part>
    public init(lens: Lens<Whole, Part>) {
        self.lens = lens
    }
}

public struct ArrayLensHelper<Whole, Element, Sub>: LensHelperType, HasSubLensHelper {
    public typealias Part = [Element]
    public typealias SubLensHelper = Sub
    public let lens: Lens<Whole, Part>
    public init(lens: Lens<Whole, Part>) {
        self.lens = lens
    }
}

public struct OptionalLensHelper<Whole, Element, Sub>: LensHelperType, HasSubLensHelper {
    public typealias Part = Element?
    public typealias SubLensHelper = Sub
    public let lens: Lens<Whole, Part>
    public init(lens: Lens<Whole, Part>) {
        self.lens = lens
    }
}

extension LensHelperType {
    public init<Parent: LensHelperType where Parent.Whole == Whole>(parent: Parent, lens: Lens<Parent.Part, Part>) {
        self.init(lens: parent.lens.compose(lens))
    }

    public func get(object: Whole) -> LensResult<Part> {
        return lens.get(object)
    }

    public func set(object: Whole, _ newValue: Part) -> LensResult<Whole> {
        return lens.set(object, newValue)
    }

    public func modify(object: Whole, @noescape closure: Part -> Part) -> LensResult<Whole> {
        return lens.modify(object, closure)
    }
}

extension ArrayLensHelper where Sub: LensHelperType, Sub.Whole == Whole, Sub.Part == Element {
    public subscript(idx: Int) -> SubLensHelper {
        return SubLensHelper(lens: lens.compose(ArrayIndexLens<Element>(at: idx)))
    }

    public func modifyMap(object: Whole, @noescape closure: Element -> Element) -> LensResult<Whole> {
        return lens.modify(object) { $0.map(closure) }
    }
}

extension OptionalLensHelper where Sub: LensHelperType, Sub.Whole == Whole, Sub.Part == Element {
    public var unwrap: SubLensHelper {
        return SubLensHelper(lens: lens.compose(OptionalUnwrapLens<Element>()))
    }
}
