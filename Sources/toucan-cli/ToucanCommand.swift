import ArgumentParser
import Toucan
import Foundation

@main
struct ToucanCommand: AsyncParsableCommand {

    @Argument(help: "The input directory (default: ./src).")
    var input: String = "./src"

    @Argument(help: "The output directory (default: ./docs).")
    var output: String = "./docs"

    func run() async throws {
        //        let generator = Toucan(
        //            inputUrl: URL(fileURLWithPath: input),
        //            outputUrl: URL(fileURLWithPath: output)
        //        )
        //        try await generator.build()
    }
}
