//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 13..
//

import Logging
import XCTest
@testable import ToucanSDK

final class ContextStoreTests: XCTestCase {

    func testContextStore() async throws {
        let logger = Logger(label: "test-logger")

        let contextStore = ContextStore(
            sourceConfig: .init(
                sourceUrl: URL(fileURLWithPath: "/"),
                config: .defaults
            ),
            contentTypes: [
                .default,
                .author,
                .post,
            ],
            pageBundles: [
                .post1,
                .author1,
                .page1,
            ],
            logger: logger
        )

        await contextStore.build()
    }
}
