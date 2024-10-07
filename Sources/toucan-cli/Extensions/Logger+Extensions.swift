//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 06..
//

import Logging
import ArgumentParser

#if compiler(>=6.0)
extension Logger.Level: @retroactive ExpressibleByArgument {}
#else
extension Logger.Level: ExpressibleByArgument {}
#endif
