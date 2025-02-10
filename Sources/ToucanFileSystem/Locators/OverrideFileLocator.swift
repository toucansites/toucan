import Foundation
import FileManagerKit

/// A structure for locating files from the filesystem.
public struct OverrideFileLocator {

    private let fileManager: FileManagerKit
    private let fileLocator: FileLocator

    init(
        fileManager: FileManagerKit,
        extensions: [String]? = nil
    ) {
        self.fileManager = fileManager
        self.fileLocator = .init(
            fileManager: fileManager,
            extensions: extensions
        )
    }

    func locate(
        at url: URL,
        overrides overridesUrl: URL
    ) -> [OverrideFileLocation] {
        let paths = fileLocator.locate(at: url)
        let overridesPaths = fileLocator.locate(at: overridesUrl)
        let overridesPathsDict = Dictionary(
            grouping: overridesPaths,
            by: \.baseName
        )

        return paths
            .map { path in
                let overridePath = overridesPathsDict[path.baseName]?.first
                return .init(path: path, overridePath: overridePath)
            }
            .sorted { $0.path < $1.path }
    }
}

/*
foo/
    bar/
        baz/
            index.markdown
            index.md
            index.yaml
            index.yml

    noindex.yml


filelocator(name: index, extensions: markdown, md, yaml, yml):
    - index.markdown
    - index.md
    - index.yaml
    - index.yml

pagebundlelocator: uses filelocator to check index / noindex files
    pageBundle.path => foo/bar/baz
    pageBundle.slug => foo/baz

toucan file system
locateFile
loacatePageBundles
listAssets

content type locator
template locator

themes
    default
        templates:
             foo.mustache
        types:
            page.yaml
            post.yaml
    overrides
        templates:
            foo.mustache
        types:
            post.yaml
            custom.yaml


content types:
    post -> default/types/post.yaml
            overrides/types/post.yaml

    pages -> default/types/page.yaml

    custom -> overrides/types/custom.yaml
*/
