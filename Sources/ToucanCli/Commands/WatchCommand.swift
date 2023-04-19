import ArgumentParser
import Dispatch
import EonilFSEvents
import Foundation
import ToucanSDK

struct WatchCommand: ParsableCommand {

    static var _commandName: String = "watch"

    @Argument(help: "The input directory.")
    var input: String = ""

    @Option(name: .shortAndLong)
    var output: String = "./dist"

    func run() throws {
        let workDir = FileManager.default.currentDirectoryPath
        let inputDir: String
        if input.hasPrefix("/") {
            inputDir = input
        }
        else {
            inputDir = workDir + "/" + input
        }

        let outputDir: String
        if output.hasPrefix("/") {
            outputDir = output
        }
        else {
            outputDir = workDir + "/" + output
        }

        let toucan = Toucan(
            inputPath: inputDir,
            outputPath: outputDir
        )

        try? toucan.generate()        
        let eventStream = try EonilFSEventStream(
            pathsToWatch: [inputDir],
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
        print("Watching: `\(inputDir)` -> \(outputDir).")
        dispatchMain()
    }
}
