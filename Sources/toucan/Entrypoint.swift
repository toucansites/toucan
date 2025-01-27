import Foundation
import Dispatch
import ShellKit

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

        let argString = args.map { "\"" + $0 + "\"" }.joined(separator: " ")
        let base = URL(fileURLWithPath: path).lastPathComponent
        let cmd = base + "-" + subcommand
        let shellCommand = "/usr/local/bin/" + cmd + " " + argString
        
        print(shellCommand)

        do {
            let shell = Shell(env: ProcessInfo.processInfo.environment)
            
            // Set up signal handler for SIGINT
            let signalSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
            signal(SIGINT, SIG_IGN) // Ignore default SIGINT behavior
            

            signalSource.setEventHandler {
                print("sigint")
                // Forward SIGINT to the subprocess
//                if process.isRunning {
//                    kill(process.processIdentifier, SIGINT)
//                }
            }
            signalSource.resume()
            
            
            let res = try shell.run(shellCommand)
            print(res)
        }
        catch let error as ShellKit.Shell.Error {
            switch error {
            case .outputData:
                print(error.localizedDescription)
            case let .generic(code, message):
                if code == 127 {
                    print("Missing subcommand: \(cmd)")
                    return
                }
                print(message)
            }
        }
        catch {
            print(error)
        }
    }
}
