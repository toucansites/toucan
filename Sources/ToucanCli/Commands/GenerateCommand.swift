import ArgumentParser
import ToucanSDK

struct GenerateCommand: ParsableCommand {

    static var _commandName: String = "generate"

    @Argument(help: "The phrase to repeat.")
    var input: String

    @Option(name: .shortAndLong)
    var output: String = "./dist"

    func run() throws {
        let toucan = Toucan(
            inputPath: input,
            outputPath: output
        )
        try toucan.generate()
    }
}
