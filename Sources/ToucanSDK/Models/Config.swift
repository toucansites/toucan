import Foundation

struct Config {
    let baseUrl: String
    let title: String
    let description: String
    let language: String

    // @TODO: return only one instance based on config
    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
}
