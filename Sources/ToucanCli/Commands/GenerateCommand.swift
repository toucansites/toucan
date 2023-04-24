import ArgumentParser
import ToucanSDK

struct GenerateCommand: ParsableCommand {

    static var _commandName: String = "generate"

    @Argument(help: "The input directory (default: src).")
    var input: String = "./src"

    @Argument(help: "The output directory (default: docs).")
    var output: String = "./docs"

    func run() throws {
        let toucan = Toucan(
            inputPath: input,
            outputPath: output
        )
        try toucan.generate()
    }
}
