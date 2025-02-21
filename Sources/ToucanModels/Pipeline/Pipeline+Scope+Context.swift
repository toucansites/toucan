//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

extension Pipeline.Scope {

    public struct Context: OptionSet, Decodable {

        public static var properties: Self { .init(rawValue: 1 << 0) }
        public static var contents: Self { .init(rawValue: 1 << 1) }
        public static var relations: Self { .init(rawValue: 1 << 2) }
        public static var queries: Self { .init(rawValue: 1 << 3) }

        // MARK: - decoder

        public init(from decoder: any Decoder) throws {
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
                    debugDescription: "Invalid Context format."
                )
            }
        }

        // MARK: -

        // TODO: separate userDefined?

        public static var reference: Self {
            [
                .properties
            ]
        }

        public static var list: Self {
            [
                .properties,
                .relations,
            ]
        }

        public static var detail: Self {
            [
                properties,
                contents,
                relations,
                queries,
            ]
        }

        public static var all: Self {
            [
                properties,
                contents,
                relations,
                queries,
            ]
        }

        // MARK: -

        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public init(stringValue: String) {
            switch stringValue.lowercased() {
            case "properties":
                self = .properties
            case "contents":
                self = .contents
            case "relations":
                self = .relations
            case "queries":
                self = .queries
            case "all":
                self = .all
            default:
                self = []
            }
        }
    }
}
