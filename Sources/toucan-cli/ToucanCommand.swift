import ArgumentParser
import Toucan
import Foundation

@main
struct ToucanCommand: ParsableCommand {

    @Argument(help: "The input directory (default: ./src).")
    var input: String = "./src"

    @Argument(help: "The output directory (default: ./docs).")
    var output: String = "./docs"

    func run() throws {
        let generator = Toucan(
            inputUrl: URL(fileURLWithPath: input),
            outputUrl: URL(fileURLWithPath: output)
        )
        try generator.build()
    }
}
