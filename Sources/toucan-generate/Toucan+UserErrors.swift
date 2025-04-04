//
//  Toucan+UserErros.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2024. 10. 07..
//

import ToucanSDK
import ToucanSource
import Logging

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
        //                    "Missing file at: `\(url.absoluteString)`."
        //                )
        //            case .file(let error, let url):
        //                let message = "File error at: `\(url.absoluteString)`."
        //                let metadata: Logger.Metadata = [
        //                    "description": "\(String(describing: error))"
        //                ]
        //                logger.error(.init(stringLiteral: message), metadata: metadata)
        //            }
        //        }
        //        catch let error as ConfigLoader.Error {
        //            switch error {
        //            case .missing(let url):
        //                logger.error(
        //                    "Missing `config.yml` file at: `\(url.absoluteString)`."
        //                )
        //            }
        //        }
        catch let error as ToucanDecoderError {
            switch error {
            case .decoding(let error, let type):
                logger.error("`\(type)` - Decoding error: `\(error)`")
            }
        }
        catch let error as ToucanEncoderError {
            switch error {
            case .encoding(let error, let type):
                logger.error("`\(type)` - Encoding error: `\(error)`")
            }
        }
        catch let error as DecodingError {
            switch error {
            case .dataCorrupted(let context):
                let underlyingError = context.underlyingError ?? error
                let description = String(describing: underlyingError)
                let message = "YAML corrupted: `\(description)`"
                logger.error(.init(stringLiteral: message))
            case .typeMismatch(_, let context):
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
        //                    "Missing site file at: `\(url.absoluteString)`."
        //                )
        //            }
        //        }
        catch {
            logger.error("\(String(describing: error))")
        }

        return false
    }
}
