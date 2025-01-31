import Foundation
import FileManagerKit

public struct ToucanFileSystem {

    let rawContentLocator: RawContentLocator
    let contentTypeLocator: OverrideFileLocator
    let templateLocator: OverrideFileLocator

    public init(fileManager: FileManagerKit) {
        self.rawContentLocator = RawContentLocator(fileManager: fileManager)
        self.contentTypeLocator = OverrideFileLocator(
            fileManager: fileManager,
            extensions: ["yaml", "yml"]
        )
        self.templateLocator = OverrideFileLocator(
            fileManager: fileManager,
            extensions: ["mustache"]
        )
    }

    func locateFiles() {

    }

    func locateRawContents(
        at url: URL
    ) -> [RawContentLocation] {
        rawContentLocator.locate(at: url)
    }

    func locateContentDefinitions(
        at url: URL,
        overrides overridesUrl: URL
    ) -> [OverrideFileLocation] {
        contentTypeLocator.locate(at: url, overrides: overridesUrl)
    }

    func locateTemplates(
        at url: URL,
        overrides overridesUrl: URL
    ) -> [OverrideFileLocation] {
        templateLocator.locate(at: url, overrides: overridesUrl)
    }
}
