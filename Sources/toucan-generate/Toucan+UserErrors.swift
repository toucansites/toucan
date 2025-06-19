//
//  Toucan+UserErrors.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2024. 10. 07..
//

import Logging
import ToucanSDK
import ToucanSerialization
import ToucanSource
import ToucanCore

extension Toucan {
    @discardableResult
    func generateAndLogErrors(_ logger: Logger) -> Bool {
        do {
            try generate()
            return true
        }
        catch let error as ToucanDecoderError {
            logger.error("\(error.logMessageStack())")
        }
        catch let error as ToucanEncoderError {
            logger.error("\(error.logMessageStack())")
        }
        catch let error as DecodingError {
            switch error {
            case let .dataCorrupted(context):
                let underlyingError = context.underlyingError ?? error
                let description = String(describing: underlyingError)
                let message = "YAML corrupted: `\(description)`"
                logger.error(.init(stringLiteral: message))
            case let .typeMismatch(_, context):
                let underlyingError = context.underlyingError ?? error
                let description = String(describing: underlyingError)
                let message = "YAML type mismatch: `\(description)`"
                logger.error(.init(stringLiteral: message))
            default:
                logger.error("\(String(describing: error))")
            }
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
