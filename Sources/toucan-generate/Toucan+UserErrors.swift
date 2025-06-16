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

extension Toucan {
    @discardableResult
    func generateAndLogErrors(_ logger: Logger) -> Bool {
        do {
            try generate()
            return true
        }

        // TODO: restore errors if needed

        //        catch let error as FileLoader.Error {
        //            switch error {
        //            case .missing(let url):
        //                logger.error(
        //                    "Missing file at: `\(url.absoluteString)`"
        //                )
        //            case .file(let error, let url):
        //                let message = "File error at: `\(url.absoluteString)`"
        //                let metadata: Logger.Metadata = [
        //                    "description": "\(String(describing: error))"
        //                ]
        //                logger.error(.init(stringLiteral: message), metadata: metadata)
        //            }
        //        }
        //        catch let error as Toucan.Error {
        //            switch error {
        //            case .duplicateSlugs(let slugs):
        //                logger.error("Duplicate slugs: \(slugs)")
        //            }
        //        }
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
        //        catch let error as PageBundleLoader.Error {
        //            switch error {
        //            case .pageBundle(let error):
        //                logger.error(
        //                    "Page bundle error: `\(String(describing: error))`"
        //                )
        //            }
        //        }
        //        catch let error as MustacheToHTMLRenderer.Error {
        //            switch error {
        //            case .missingTemplate(let value):
        //                logger.error(
        //                    "Missing template file: `\(value)`"
        //                )
        //            }
        //        }
        //        catch let error as SiteLoader.Error {
        //            switch error {
        //            case .missing(let url):
        //                logger.error(
        //                    "Missing site file at: `\(url.absoluteString)`"
        //                )
        //            }
        //        }
        catch {
            logger.error("\(String(describing: error))")
        }

        return false
    }
}
