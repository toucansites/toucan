import ArgumentParser
import Foundation
import Hummingbird
import HummingbirdFoundation
import ToucanSDK

protocol AppArguments {
    var dir: String { get }
}

extension HBApplication {

    func configure(_ args: AppArguments) throws {

        let workDir: String
        if args.dir.hasPrefix("/") {
            workDir = args.dir
        }
        else {
            workDir = FileManager.default.currentDirectoryPath + "/" + args.dir
        }

        middleware.add(
            HBFileMiddleware(
                workDir,
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
    var dir: String = ""

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
