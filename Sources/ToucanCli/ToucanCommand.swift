import ArgumentParser
import ToucanSDK

/*@main
struct ToucanCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        subcommands: [
            GenerateCommand.self,
            ServeCommand.self,
            WatchCommand.self,
        ],
        defaultSubcommand: GenerateCommand.self
    )
}*/

@main
struct ToucanCommand {
    static func main() throws {
        let toucan = Toucan(
            inputPath: "./src",
            outputPath: "./dist"
        )
        try toucan.generate(nil)
    }
}
