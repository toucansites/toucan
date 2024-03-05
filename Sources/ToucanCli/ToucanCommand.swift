import ArgumentParser
import ToucanSDK

@main
struct ToucanCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        subcommands: [
            GenerateCommand.self,
            ServeCommand.self,
            WatchCommand.self,
        ],
        defaultSubcommand: GenerateCommand.self
    )
}