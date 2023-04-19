import ArgumentParser
import Foundation
import Hummingbird
import HummingbirdFoundation
import ToucanSDK

protocol AppArguments {
    var path: String { get }
}

extension HBApplication {

    func configure(_ args: AppArguments) throws {

        let workPath: String
        if args.path.hasPrefix("/") {
            workPath = args.path
        }
        else if args.path.hasPrefix("~") {
            let homePath = FileManager.default.homeDirectoryForCurrentUser.path
            workPath = homePath + "/" + String(args.path.dropFirst())
        }
        else {
            let currentPath = FileManager.default.currentDirectoryPath
            workPath = currentPath + "/" + args.path
        }

        middleware.add(
            HBFileMiddleware(
                workPath,
                searchForIndexHtml: true,
                application: self
            )
        )
    }
}

struct ServeCommand: ParsableCommand, AppArguments {

    static var _commandName: String = "serve"

    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    @Option(name: .shortAndLong)
    var path: String = "."

    func run() throws {
        let app = HBApplication(
            configuration: .init(
                address: .hostname(hostname, port: port),
                serverName: "Toucanbird"
            )
        )
        try app.configure(self)
        try app.start()
        app.wait()
    }
}
