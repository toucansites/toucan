import Foundation
import ArgumentParser
import Dispatch
import EonilFSEvents
import ToucanSDK

extension Entrypoint {

    struct Watch: ParsableCommand {

        static var _commandName: String = "watch"

        @Argument(help: "The input directory (default: src).")
        var input: String = "./src"

        @Argument(help: "The output directory (default: docs).")
        var output: String = "./docs"

        @Option(name: .shortAndLong, help: "The base url to use.")
        var baseUrl: String? = nil

        func run() throws {
            let toucan = Toucan(
                input: input,
                output: output,
                baseUrl: baseUrl
            )
            try toucan.generate()

            let eventStream = try EonilFSEventStream(
                pathsToWatch: [input],
                sinceWhen: .now,
                latency: 0,
                flags: [],
                handler: { event in
                    guard let flag = event.flag, flag == [] else {
                        return
                    }
                    print("Generating site...")
                    do {
                        try toucan.generate()
                    }
                    catch {
                        print("\(error)")
                    }
                    print("Site re-generated.")
                }
            )

            eventStream.setDispatchQueue(DispatchQueue.main)

            try eventStream.start()
            print("👀 Watching: `\(input)` -> \(output).")
            dispatchMain()
        }
    }
}
