import Foundation
import FileManagerKit

/// A structure for locating files from the filesystem.
public struct FileLocator {

    /// The file manager used for accessing the filesystem.
    private let fileManager: FileManagerKit

    let name: String?

    /// An array of file extensions to search for when loading files.
    let extensions: [String]?

    public init(
        fileManager: FileManagerKit,
        name: String? = nil,
        extensions: [String]? = nil
    ) {
        self.fileManager = fileManager
        self.name = name
        self.extensions = extensions
    }

    /// Loads the contents of files at the specified URL.
    ///
    /// - Parameter url: The base URL to look for files.
    /// - Returns: An array of file contents as strings.
    public func locate(at url: URL) -> [String] {
        fileManager
            .listDirectory(at: url)
            .filter { fileName in
                let url = URL(fileURLWithPath: fileName)
                let baseName = url.deletingPathExtension().lastPathComponent
                let ext = url.pathExtension

                switch (name, extensions) {
                case (nil, nil):
                    return true
                case (let name?, nil):
                    return baseName == name
                case (nil, let extensions?):
                    return extensions.contains(ext)
                case (let name?, let extensions?):
                    return baseName == name && extensions.contains(ext)
                }
            }
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
