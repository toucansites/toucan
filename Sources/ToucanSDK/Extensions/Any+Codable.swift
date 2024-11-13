//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 19..
//

import Foundation

func encodeValue(
    fromObjectContainer container: inout KeyedEncodingContainer<JSONCodingKeys>,
    map: [String: Any]
) throws {
    for k in map.keys {
        let value = map[k]
        let encodingKey = JSONCodingKeys(stringValue: k)

        if let value = value as? Encodable {
            try container.encode(value, forKey: encodingKey)
        }
        else if let value = value as? [String: Any] {
            var keyedContainer = container.nestedContainer(
                keyedBy: JSONCodingKeys.self,
                forKey: encodingKey
            )
            try encodeValue(fromObjectContainer: &keyedContainer, map: value)
        }
        else if let value = value as? [Any] {
            var unkeyedContainer = container.nestedUnkeyedContainer(
                forKey: encodingKey
            )
            try encodeValue(fromArrayContainer: &unkeyedContainer, arr: value)
        }
        else {
            try container.encodeNil(forKey: encodingKey)
        }
    }
}

func encodeValue(
    fromArrayContainer container: inout UnkeyedEncodingContainer,
    arr: [Any]
) throws {
    for value in arr {
        if let value = value as? Encodable {
            try container.encode(value)
        }
        else if let value = value as? [String: Any] {
            var keyedContainer = container.nestedContainer(
                keyedBy: JSONCodingKeys.self
            )
            try encodeValue(fromObjectContainer: &keyedContainer, map: value)
        }
        else if let value = value as? [Any] {
            var unkeyedContainer = container.nestedUnkeyedContainer()
            try encodeValue(fromArrayContainer: &unkeyedContainer, arr: value)
        }
        else {
            try container.encodeNil()
        }
    }
}

struct JSONCodingKeys: CodingKey {
    var stringValue: String

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

struct JSON: Encodable {
    var value: Any?

    init(value: Any?) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        if let map = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKeys.self)
            try encodeValue(fromObjectContainer: &container, map: map)
        }
        else if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try encodeValue(fromArrayContainer: &container, arr: arr)
        }
        else {
            var container = encoder.singleValueContainer()
            if let value = self.value as? Encodable {
                try container.encode(value)
            }
            else {
                try container.encodeNil()
            }
        }
    }
}
