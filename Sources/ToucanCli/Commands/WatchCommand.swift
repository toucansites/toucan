import ArgumentParser
import Dispatch
import EonilFSEvents
import Foundation
import ToucanSDK

struct WatchCommand: ParsableCommand {

    static var _commandName: String = "watch"

    @Argument(help: "The input directory.")
    var input: String

    @Argument(help: "The output directory.")
    var output: String = "./docs"
    
    func run() throws {
        let toucan = Toucan(
            inputPath: input,
            outputPath: output
        )

        try? toucan.generate()        
        let eventStream = try EonilFSEventStream(
            pathsToWatch: [toucan.inputUrl.path],
            sinceWhen: .now,
            latency: 0,
            flags: [],
            handler: { event in
                guard let flag = event.flag, flag == [] else {
                    return
                }
                print("Generating site...")
                try? toucan.generate()
                print("Site re-generated.")
            })
        
        eventStream.setDispatchQueue(DispatchQueue.main)
        
        try eventStream.start()
        print("Watching: `\(toucan.inputUrl.path)` -> \(toucan.outputUrl.path).")
        dispatchMain()
    }
}
