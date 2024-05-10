import Foundation

extension String {

    func slugified() -> String {
        let allowed = CharacterSet(
            charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-_."
        )
        return trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .folding(
                options: .diacriticInsensitive,
                locale: .init(identifier: "en_US")
            )
            .components(separatedBy: allowed.inverted)
            .filter { $0 != "" }
            .joined(separator: "-")
    }

    func replacingOccurrences(
        _ dictionary: [String: String]
    ) -> String {
        var result = self
        let sorted = dictionary.sorted(by: <)
        for (key, value) in sorted {
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result
    }

    func replacingTemplateVariables(
        _ dictionary: [String: String],
        _ prefix: String? = nil
    ) -> String {
        var values: [String: String] = [:]

        var pre = ""
        if let prefix {
            pre = prefix + "."
        }

        for (key, value) in dictionary {
            values["{" + pre + key + "}"] = value
        }
        return replacingOccurrences(values)
    }

    func slice(
        from: String,
        to: String
    ) -> String? {
        guard
            let fromIndex = range(of: from)?.upperBound,
            let toIndex = self[fromIndex...].range(of: to)?.lowerBound
        else {
            return nil
        }
        return String(self[fromIndex..<toIndex])
    }
}
