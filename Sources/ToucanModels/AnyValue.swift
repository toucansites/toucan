//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

public struct AnyValue {

    public let value: Any

    public init(value: Any) {
        self.value = value
    }

}

//
//extension AnyValue: ExpressibleByBooleanLiteral {
//
//    public init(booleanLiteral value: BooleanLiteralType) {
//        self.value = value
//    }
//}
//
//extension AnyValue: ExpressibleByIntegerLiteral {
//
//    public init(integerLiteral value: IntegerLiteralType) {
//        self.value = value
//    }
//}
//
//extension AnyValue: ExpressibleByFloatLiteral {
//
//    public init(floatLiteral value: FloatLiteralType) {
//        self.value = value
//    }
//}
//
//extension AnyValue: ExpressibleByStringLiteral {
//
//    public init(stringLiteral value: StringLiteralType) {
//        self.value = value
//    }
//}
//
//extension AnyValue: ExpressibleByStringInterpolation {
//
//    public struct StringInterpolation: StringInterpolationProtocol {
//        var output = ""
//
//        public init(literalCapacity: Int, interpolationCount: Int) {
//            output.reserveCapacity(literalCapacity)
//        }
//
//        public mutating func appendLiteral(_ literal: String) {
//            output += literal
//        }
//
//        public mutating func appendInterpolation<T>(_ value: T) {
//            output += "\(value)"
//        }
//    }
//
//    public init(stringInterpolation: StringInterpolation) {
//        self.value = stringInterpolation.output
//    }
//}
//
//extension AnyValue: ExpressibleByArrayLiteral {
//
//    public typealias ArrayLiteralElement = AnyValue
//
//    public init(arrayLiteral elements: ArrayLiteralElement...) {
//        self.value = elements
//    }
//}
//
//extension AnyValue: ExpressibleByDictionaryLiteral {
//    public typealias Key = String
//    public typealias Value = AnyValue
//
//    public init(dictionaryLiteral elements: (Key, Value)...) {
//        self.value = elements
//    }
//}
