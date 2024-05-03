import ArgumentParser
import Toucan

@main
struct ToucanCommand: ParsableCommand {

    @Argument(help: "The input directory (default: ./src).")
    var input: String = "./src"

    @Argument(help: "The output directory (default: ./docs).")
    var output: String = "./docs"

    @Option(name: .shortAndLong, help: "The base url to use.")
    var baseUrl: String? = nil

    func run() throws {
        let toucan = Toucan(
            inputPath: input,
            outputPath: output
        )
        try toucan.generate(baseUrl)
    }
}
