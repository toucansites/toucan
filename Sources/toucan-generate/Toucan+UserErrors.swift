//
//  Toucan+UserErrors.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2024. 10. 07..
//

import Foundation
import Logging
import ToucanSDK
import ToucanSerialization
import ToucanSource
import ToucanCore

extension Toucan {

    @discardableResult
    func generateAndLogErrors(
        workDir: String,
        targetsToBuild: [String],
        now: Date
    ) -> Bool {
        do {
            try generate(
                workDir: workDir,
                targetsToBuild: targetsToBuild,
                now: now
            )
            return true
        }
        catch let error as ToucanError {
            logger.error("\(error.logMessageStack())")
        }
        catch {
            logger.error("\(error)")
        }
        return false
    }
}
