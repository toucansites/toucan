//
//  Slug.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 03.
//
    
public struct Slug: Codable, Equatable {
    
    public var value: String
    
    public init(value: String) {
        self.value = value
    }
    
    public func resolveForPath() -> String {
        return value.isEmpty ? "home" : value
    }
    
    public func extractIteratorId() -> String? {
        guard
            let startRange = value.range(of: "{{"),
            let endRange = value.range(
                of: "}}",
                range: startRange.upperBound..<value.endIndex
            )
        else {
            return nil
        }
        return .init(value[startRange.upperBound..<endRange.lowerBound])
    }
    
    public func permalink(
        baseUrl: String
    ) -> String {
        let components = value.split(separator: "/").map(String.init)
        if components.isEmpty {
            return baseUrl
        }
        if components.last?.split(separator: ".").count ?? 0 > 1 {
            return ([baseUrl] + components).joined(separator: "/")
        }
        return ([baseUrl] + components).joined(separator: "/") + "/"
    }
    
    public func contextAwareIdentifier() -> String {
        return String(value.split(separator: "/").last ?? "")
    }
    
}
