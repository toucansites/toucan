//
//  Config+Renderer+ParagraphStyles.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 17..
//

public extension Config.RendererConfig {
    /// Defines paragraph style aliases for block-level directives
    struct ParagraphStyles: Codable, Equatable {
        // MARK: - Static Computed Properties

        // MARK: - Defaults

        /// Returns a standard `ParagraphStyles` configuration with common alias values.
        public static var defaults: Self {
            .init(
                styles: [
                    "note": ["note"],
                    "warning": ["warn", "warning"],
                    "tip": ["tip"],
                    "important": ["important"],
                    "error": ["error", "caution"],
                ]
            )
        }

        // MARK: - Properties

        /// A dictionary mapping style group names to arrays of individual paragraph styles.
        public var styles: [String: [String]]

        // MARK: - Lifecycle

        // MARK: - Initialization

        /// Initializes a new object with custom style mappings.
        ///
        /// - Parameter styles: A style group representing the paragraph styles.
        public init(
            styles: [String: [String]],
        ) {
            self.styles = styles
        }

        /// Initializes a new instance by decoding from the given decoder.
        ///
        /// - Parameter decoder: The decoder to read data from.
        /// - Throws: Only throws if the underlying decoding attempt throws unexpectedly;
        ///           otherwise silently falls back to defaults.
        public init(
            from decoder: Decoder
        ) throws {
            guard
                let container = try? decoder.singleValueContainer(),
                let styles = try? container.decode([String: [String]].self)
            else {
                self.styles = Self.defaults.styles
                return
            }
            self.styles = styles
        }

        // MARK: - Functions

        /// Encodes this  instance into the given encoder.
        ///
        /// - Parameter encoder: The encoder to write data to.
        /// - Throws: An error if any value is invalid for the given encoder’s format.
        public func encode(
            to encoder: Encoder
        ) throws {
            var container = encoder.singleValueContainer()
            try container.encode(styles)
        }
    }
}
