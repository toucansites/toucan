//
//  ContentFilter.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 18..
//

import ToucanModels

/// A utility that filters content based on specified conditions.
///
/// `ContentFilter` applies filtering logic to collections of `Content` items,
/// using a dictionary of conditions keyed by content type identifiers.
struct ContentFilter {

    /// A dictionary mapping content type identifiers to filtering conditions.
    let filterRules: [String: Condition]

    /// Applies the filtering rules to the provided content items.
    ///
    /// - Parameter contents: The list of `Content` items to filter.
    /// - Returns: A new list containing only the filtered content items.
    func applyRules(
        contents: [Content]
    ) -> [Content] {
        let groups = Dictionary(grouping: contents, by: { $0.definition.id })

        var result: [Content] = []
        for (id, contents) in groups {
            if let condition = filterRules[id] ?? filterRules["*"] {
                let items = contents.run(
                    query: .init(
                        contentType: id,
                        filter: condition,
                    )
                )
                result.append(contentsOf: items)
            }
            else {
                result.append(contentsOf: contents)
            }
        }
        return result
    }

}
