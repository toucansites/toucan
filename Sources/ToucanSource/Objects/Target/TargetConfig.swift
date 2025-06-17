//
//  TargetConfig.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 15..
//

/// A structure that holds a list of deployment targets and resolves the default one.
public struct TargetConfig: Codable, Equatable {
    // MARK: - Nested Types

    // MARK: - Coding Keys

    /// Keys explicitly defined for decoding known fields from the input source.
    enum CodingKeys: CodingKey {
        case targets
    }

    // MARK: - Static Computed Properties

    // MARK: - Defaults

    /// Default values used when decoding fails or fields are missing.
    private static var base: Self {
        .init(targets: [Target.standard])
    }

    // MARK: - Properties

    /// All defined targets.
    public var targets: [Target]

    // MARK: - Computed Properties

    /// The default target (first one with `isDefault == true`, or first in the list, or fallback).
    public var `default`: Target {
        targets.first(where: { $0.isDefault }) ?? targets[0]
    }

    // MARK: - Lifecycle

    // MARK: - Initialization

    /// Creates a new `Targets` object.
    /// - Parameter targets: An array of deployment targets.
    /// - Precondition: Only one target may have `isDefault == true`.
    public init(
        targets: [Target]
    ) {
        let defaultCount = targets.filter(\.isDefault).count
        precondition(
            defaultCount <= 1,
            "Only one target can be marked as default."
        )

        var all = targets
        if !all.isEmpty, defaultCount == 0 {
            all[0].isDefault = true
        }
        self.targets = all.isEmpty ? Self.base.targets : all
    }

    // MARK: - Decoding Logic

    /// Custom decoder with fallback values and default validation.
    ///
    /// - Parameter decoder: The decoer used to decode values.
    /// - Throws: An error if any values are invalid for the given encoder’s format.
    public init(
        from decoder: any Decoder
    ) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        let all =
            try container?
            .decodeIfPresent(
                [Target].self,
                forKey: .targets
            ) ?? []

        let defaultCount = all.filter(\.isDefault).count
        guard defaultCount <= 1 else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container?.codingPath ?? [],
                    debugDescription:
                        "Only one target can be marked as default."
                )
            )
        }
        self.init(targets: all)
    }

    // MARK: - Functions

    /// Encodes this instance into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if any values are invalid for the given encoder’s format.
    public func encode(
        to encoder: any Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(targets, forKey: .targets)
    }
}
