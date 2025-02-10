import Foundation
import FileManagerKit

public struct ToucanFileSystem {

    let rawContentLocator: RawContentLocator
    let contentTypeLocator: OverrideFileLocator
    let templateLocator: TemplateLocator

    public init(fileManager: FileManagerKit) {
        self.rawContentLocator = RawContentLocator(fileManager: fileManager)
        self.contentTypeLocator = OverrideFileLocator(
            fileManager: fileManager,
            extensions: ["yaml", "yml"]
        )
        self.templateLocator = TemplateLocator(fileManager: fileManager)
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
    ) -> [TemplateLocation] {
        templateLocator.locate(at: url, overridesUrl: overridesUrl)
    }
}
