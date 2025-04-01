import Foundation
import FileManagerKit
import ToucanModels

public struct ToucanFileSystem {

    public let configLocator: FileLocator
    public let settingsLocator: FileLocator
    public let assetLocator: AssetLocator
    public let pipelineLocator: FileLocator
    public let ymlFileLocator: OverrideFileLocator
    public let rawContentLocator: RawContentLocator
    public let templateLocator: TemplateLocator

    public init(fileManager: FileManagerKit) {
        self.configLocator = FileLocator(
            fileManager: fileManager,
            name: "config",
            extensions: ["yml", "yaml"]
        )
        self.settingsLocator = FileLocator(
            fileManager: fileManager,
            name: "site",
            extensions: ["yml", "yaml"]
        )
        self.assetLocator = AssetLocator(fileManager: fileManager)
        self.pipelineLocator = FileLocator(
            fileManager: fileManager,
            extensions: ["yml", "yaml"]
        )
        self.ymlFileLocator = OverrideFileLocator(
            fileManager: fileManager,
            extensions: ["yml", "yaml"]
        )
        self.rawContentLocator = RawContentLocator(fileManager: fileManager)
        self.templateLocator = TemplateLocator(fileManager: fileManager)
    }
}
