//
//  Toucan+UserErrors.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2024. 10. 07..
//

import Logging
import ToucanSDK
import ToucanCore

extension Toucan {

    @discardableResult
    func generateAndLogErrors(_ logger: Logger) -> Bool {
        do {
            try generate()
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
