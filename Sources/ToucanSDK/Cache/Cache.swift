//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 13..
//

import Dispatch

// TODO: use actor & modern concurrency
final class Cache {

    let q = DispatchQueue(
        label: "com.toucansites.toucan.cache",
        attributes: .concurrent
    )

    var storage: [String: Any]

    init() {
        self.storage = [:]
    }

    func set(key: String, value: Any) {
        q.async(flags: .barrier) {
            self.storage[key] = value
        }

    }

    func get(key: String) -> Any? {
        q.sync {
            self.storage[key]
        }
    }
}
