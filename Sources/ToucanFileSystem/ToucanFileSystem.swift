import Foundation
import FileManagerKit

public struct ToucanFileSystem {

    let pageBundleLocator: PageBundleLocator
    let contentTypeLocator: OverrideFileLocator
    let templateLocator: OverrideFileLocator

    public init(fileManager: FileManagerKit) {
        self.pageBundleLocator = PageBundleLocator(fileManager: fileManager)
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
    
    func locatePageBundles(at url: URL) -> [PageBundleLocation] {
        pageBundleLocator.locate(at: url)
    }
    
    func locateContentTypes(
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
