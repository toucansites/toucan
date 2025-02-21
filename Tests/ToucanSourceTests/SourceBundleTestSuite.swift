import Foundation
import Testing
import ToucanModels
import ToucanTesting
@testable import ToucanSource

@Suite
struct SourceBundleTestSuite {

    // MARK: -

    @Test
    func rss() throws {

        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .init(secondsFromGMT: 0)

        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let nowString = formatter.string(from: now)

        let pipelines = [
            Pipeline.Mocks.rss()
        ]

        let postDefinition = ContentDefinition.Mocks.post()
        let rawPostContents = RawContent.Mocks.posts(
            max: 1,
            now: now,
            formatter: formatter
        )
        let postContents = rawPostContents.map {
            postDefinition.convert(
                rawContent: $0,
                definition: postDefinition,
                using: formatter
            )
        }

        // rss
        let rssDefinition = ContentDefinition.Mocks.rss()
        let rawRSSContents = RawContent.Mocks.rss()
        let rssContents = rawRSSContents.map {
            rssDefinition.convert(
                rawContent: $0,
                definition: rssDefinition,
                using: formatter
            )
        }

        let contentBundles: [ContentBundle] = [
            .init(definition: postDefinition, contents: postContents),
            .init(definition: rssDefinition, contents: rssContents),
        ]

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: .defaults,
            settings: .defaults,
            pipelines: pipelines,
            contentBundles: contentBundles
        )

        let templates: [String: String] = [
            "rss": Templates.Mocks.rss()
        ]

        let results = try sourceBundle.generatePipelineResults(
            templates: templates
        )

        #expect(results.count == 1)

        let expectation = #"""
            <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
            <channel>
                <title></title>
                <description></description>
                <link>http://localhost:3000</link>
                <language></language>
                <lastBuildDate>\#(nowString)</lastBuildDate>
                <pubDate>\#(nowString)</pubDate>
                <ttl>250</ttl>
                <atom:link href="http://localhost:3000rss.xml" rel="self" type="application/rss+xml"/>

            <item>
                <guid isPermaLink="true">http://localhost:3000/blog/posts/post-1/</guid>
                <title><![CDATA[ Post #1 ]]></title>
                <description><![CDATA[  ]]></description>
                <link>http://localhost:3000/blog/posts/post-1/</link>
                <pubDate>\#(nowString)</pubDate>
            </item>



            </channel>
            </rss>
            """#

        #expect(results[0].contents == expectation)
        #expect(results[0].destination.path == "")
        #expect(results[0].destination.file == "rss")
        #expect(results[0].destination.ext == "xml")
    }

    @Test
    func pipelineRendering() throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        // TODO: add support for multiple engines: [mustache: [foo: tpl1]]
        let templates: [String: String] = [
            "default": Templates.Mocks.default(),
            "post.default": Templates.Mocks.post(),
            "rss": Templates.Mocks.rss(),
        ]

        let homeUrl = FileManager.default.homeDirectoryForCurrentUser
        let url = homeUrl.appending(
            path: "output"
        )

        if FileManager.default.exists(at: url) {
            try FileManager.default.removeItem(at: url)
        }
        try FileManager.default.createDirectory(at: url)

        let results = try sourceBundle.generatePipelineResults(
            templates: templates
        )

        for result in results {
            let folder = url.appending(path: result.destination.path)
            try FileManager.default.createDirectory(at: folder)

            let outputUrl =
                folder
                .appending(path: result.destination.file)
                .appendingPathExtension(result.destination.ext)

            try result.contents.write(
                to: outputUrl,
                atomically: true,
                encoding: .utf8
            )
        }
    }

}
