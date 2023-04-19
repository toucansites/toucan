import ArgumentParser
import ToucanSDK

struct GenerateCommand: ParsableCommand {

    static var _commandName: String = "generate"

    @Argument(help: "The input directory.")
    var input: String

    @Argument(help: "The output directory.")
    var output: String = "./docs"

    func run() throws {
        let toucan = Toucan(
            inputPath: input,
            outputPath: output
        )
        try toucan.generate()
    }
}
