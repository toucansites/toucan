import Foundation
import ArgumentParser
import ToucanSDK
import Logging

#if os(macOS)
import Dispatch
import EonilFSEvents
// TODO: use async sequence for file watcher + Linux support
let semaphore = DispatchSemaphore(value: 0)
private var lastGenerationTime: Date?

func waitForever() {
    semaphore.wait()
}
#endif

extension Entrypoint {

    struct Watch: AsyncParsableCommand {

        static var _commandName: String = "watch"

        @Argument(help: "The input directory (default: src).")
        var input: String = "./src"

        @Argument(help: "The output directory (default: docs).")
        var output: String = "./docs"

        @Option(name: .shortAndLong, help: "The base url to use.")
        var baseUrl: String? = nil
        
        @Option(name: .shortAndLong, help: "The log level to use.")
        var logLevel: Logger.Level = .info


        mutating func run() async throws {
            var logger = Logger(label: "toucan")
            logger.logLevel = logLevel
            
            logger.info("👀 Watching: `\(input)` -> \(output).")
            
            let generator = Toucan(
                input: input,
                output: output,
                baseUrl: baseUrl,
                logger: logger
            )
            generator.generateAndLogErrors(logger)

            #if os(macOS)
            let eventStream = try EonilFSEventStream(
                pathsToWatch: [input],
                sinceWhen: .now,
                latency: 0,
                flags: [],
                handler: { event in
                    guard let flag = event.flag, flag == [] else {
                        return
                    }
                    let now = Date()
                    let last = lastGenerationTime ?? now
                    let diff = abs(last.timeIntervalSince(now))
                    // 3 sec delay
                    guard (diff == 0) || (diff > 3) else {
                        return
                    }

                    logger.info("Generating site...")
                    generator.generateAndLogErrors(logger)
                    logger.info("Site re-generated.")
                }
            )

            eventStream.setDispatchQueue(DispatchQueue.main)

            try eventStream.start()
            waitForever()
            #else
            logger.info("👀 This is a macOS only feature for now.")
            #endif
        }
    }
}
