//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

extension Pipeline.Scope {

    public struct Context: OptionSet, Decodable {
        // simple contexts
        public static var userDefined: Self { .init(rawValue: 1 << 0) }
        public static var properties: Self { .init(rawValue: 1 << 1) }
        public static var contents: Self { .init(rawValue: 1 << 2) }
        public static var relations: Self { .init(rawValue: 1 << 3) }
        public static var queries: Self { .init(rawValue: 1 << 4) }

        // MARK: - decoder

        public init(
            from decoder: any Decoder
        ) throws {
            let container = try decoder.singleValueContainer()
            if let stringValue = try? container.decode(String.self) {
                self.init(stringValue: stringValue)
            }
            else if let stringArray = try? container.decode([String].self) {
                self = stringArray.reduce(into: []) {
                    $0.insert(.init(stringValue: $1))
                }
            }
            else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid context format."
                )
            }
        }

        // MARK: - compound contexts

        public static var reference: Self {
            [
                .userDefined,
                .properties,
                .relations,
                .contents,
                .queries,
            ]
        }

        public static var list: Self {
            [
                .userDefined,
                .properties,
                .relations,
                .contents,
                .queries,
            ]
        }

        public static var detail: Self {
            [
                .userDefined,
                .properties,
                .relations,
                .contents,
                .queries,
            ]
        }

        // MARK: - raw value

        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        // MARK: - string value

        public init(stringValue: String) {
            switch stringValue.lowercased() {
            // simple contexts
            case "userDefined":
                self = .userDefined
            case "properties":
                self = .properties
            case "contents":
                self = .contents
            case "relations":
                self = .relations
            case "queries":
                self = .queries
            // compund contexts
            case "reference":
                self = .reference
            case "list":
                self = .list
            case "detail":
                self = .detail
            // default to empty
            default:
                self = []
            }
        }
    }
}
