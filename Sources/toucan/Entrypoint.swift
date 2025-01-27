import Foundation
import Dispatch
import SwiftCommand

extension Array {

    mutating func popFirst() -> Element? {
        isEmpty ? nil : removeFirst()
    }
}

/// The main entry point for the command-line tool.
@main
struct Entrypoint {

    static func main() async throws {
        var args = CommandLine.arguments

        guard
            args.count > 1,
            let path = args.popFirst(),
            let subcommand = args.popFirst()
        else {
            fatalError("argument error")
        }

        let base = URL(fileURLWithPath: path).lastPathComponent
        let toucanCmd = base + "-" + subcommand

        guard let exe = Command.findInPath(withName: toucanCmd) else {
            fatalError("Command not found (\(toucanCmd)).")
        }
        let cmd = exe
            .addArguments(args)
            .setStdin(.pipe(closeImplicitly: false))
            .setStdout(.inherit)
            .setStderr(.inherit)
        
        let subprocess = try cmd.spawn()

        let signalSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
        signal(SIGINT, SIG_IGN) // Ignore default SIGINT behavior

        signalSource.setEventHandler {
            if subprocess.isRunning {
                kill(subprocess.identifier, SIGINT)
            }
        }
        signalSource.resume()
       
        try subprocess.wait()
    }
}
