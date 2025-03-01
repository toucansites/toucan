import Foundation
import FileManagerKit
import ToucanModels

public struct ToucanFileSystem {

    let rawContentLocator: RawContentLocator
    let contentDefinitionLocator: OverrideFileLocator
    let templateLocator: TemplateLocator

    public init(fileManager: FileManagerKit) {
        self.rawContentLocator = RawContentLocator(fileManager: fileManager)
        self.contentDefinitionLocator = OverrideFileLocator(
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
        contentDefinitionLocator.locate(at: url, overrides: overridesUrl)
    }

    func locateTemplates(
        at url: URL,
        overrides overridesUrl: URL
    ) -> [TemplateLocation] {
        templateLocator.locate(at: url, overridesUrl: overridesUrl)
    }
    
    func loadContentDefinitions(
        _ locations: [OverrideFileLocation]
    ) -> [ContentDefinition] {
        [
            .init(
                type: "test",
                paths: [],
                properties: [:],
                relations: [:],
                queries: [:]
            )
        ]
    }
}
