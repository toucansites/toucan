//
//  Targets.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 15..
//

/// A structure that holds a list of deployment targets and resolves the default one.
public struct Targets: Decodable, Equatable {

    // MARK: - Coding Keys

    /// Keys explicitly defined for decoding known fields from the input source.
    enum CodingKeys: CodingKey {
        case targets
    }

    // MARK: - Properties

    /// All defined targets.
    public var all: [Target]

    /// The default target (first one with `isDefault == true`, or first in the list, or fallback).
    public var `default`: Target {
        all.first(where: { $0.isDefault }) ?? all[0]
    }

    // MARK: - Defaults

    /// Default values used when decoding fails or fields are missing.
    public static var defaults: Self {
        .init(all: [Target.default])
    }

    // MARK: - Initialization

    /// Creates a new `Targets` object.
    /// - Parameter all: An array of deployment targets.
    /// - Precondition: Only one target may have `isDefault == true`.
    public init(all: [Target]) {
        print(all);
        let defaultCount = all.filter(\.isDefault).count
        print(defaultCount)
        precondition(defaultCount <= 1, "Only one target can be marked as default.")
        
        var all = all
        if !all.isEmpty, defaultCount == 0 {
            all[0].isDefault = true
        }
        self.all = all.isEmpty ? Self.defaults.all : all
    }

    // MARK: - Decoding Logic

    /// Custom decoder with fallback values and default validation.
    public init(from decoder: any Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        let all = try container?.decodeIfPresent(
            [Target].self,
            forKey: .targets
        ) ?? []

        let defaultCount = all.filter(\.isDefault).count
        guard defaultCount <= 1 else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container?.codingPath ?? [],
                    debugDescription: "Only one target can be marked as default."
                )
            )
        }
        self.init(all: all)
    }
}
