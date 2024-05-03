//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

//import XCTest
//@testable import ToucanSDK
//
//final class AppTests: XCTestCase {
//
//    func testPosts() throws {
//
//        var toucanFilesKit = ToucanFilesKit()
//        try toucanFilesKit.createURLs(URL(fileURLWithPath: "./Tests/src"))
//        try toucanFilesKit.createInfo(needToCopy: false)
//
//        var toucanContentKit = ToucanContentKit()
//        try toucanContentKit.create(
//            baseUrl: nil,
//            contentsUrl: toucanFilesKit.contentsUrl,
//            templatesUrl: toucanFilesKit.templatesUrl,
//            postFileInfos: toucanFilesKit.postFileInfos,
//            pageFileInfos: toucanFilesKit.pageFileInfos
//        )
//
//        for post in toucanContentKit.posts {
//            let content = try post.generate()
//            let distUrl = URL(fileURLWithPath: "./Tests/dist/").appendingPathComponent(post.slug).appendingPathComponent("/index.html")
//            let goalContent = try String(contentsOf: distUrl)
//            XCTAssertEqual(content, goalContent)
//        }
//
//    }
//}
