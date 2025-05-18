//
//  URL+Extensions.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 17..
//

import Foundation

public extension URL {

    /// Returns a new URL by appending the given path component if it is non-nil and not empty.
    ///
    /// This method is useful when working with optional path components where you want to
    /// conditionally append the value only if it's meaningful (i.e., not `nil` or an empty string).
    ///
    /// - Parameter path: An optional string representing the path component to append.
    /// - Returns: A new `URL` with the appended path component if valid; otherwise, the original URL.
    ///
    /// ## Example
    /// ```swift
    /// let baseURL = URL(string: "https://example.com/api")!
    /// let endpoint: String? = "users"
    /// let fullURL = baseURL.appendingPathIfPresent(endpoint)
    /// // fullURL: https://example.com/api/users
    /// ```
    func appendingPathIfPresent(_ path: String?) -> URL {
        guard let path, !path.isEmpty else {
            return self
        }
        return appending(path: path)
    }
}
