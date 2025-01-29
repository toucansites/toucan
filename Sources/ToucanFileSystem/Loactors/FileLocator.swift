import Foundation
import FileManagerKit

/// A structure for locating files from the filesystem.
public struct FileLocator {

    /// The file manager used for accessing the filesystem.
    let fileManager: FileManagerKit

    let name: String?

    /// An array of file extensions to search for when loading files.
    let extensions: [String]?

    /// Loads the contents of files at the specified URL.
    /// - Parameter url: The base URL to look for files.
    /// - Returns: An array of file contents as strings.
    /// - Throws: An error of type `FileLoader.Error` if the files cannot be found or read.
    func locate(at url: URL) throws -> [String] {
        return fileManager.listDirectory(at: url)
            //        .filter {
            //            fileManager.fileExists(at: url.appending(path: $0))
            //        }
            .filter {
                extensions?.map { name ?? "" + "." + $0 }.contains($0) ?? true
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
