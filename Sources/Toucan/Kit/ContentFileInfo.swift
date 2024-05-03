import Foundation

struct ContentFileInfo {

    let url: URL
    let contentsUrl: URL
    let modificationDate: Date
    let metaData: [String: String]
    let availableAssets: [String]
    let hasPostImage: Bool

}
