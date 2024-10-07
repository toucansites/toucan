//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 07..
//

import ToucanSDK
import Logging

extension Toucan {

    func generateAndLogErrors(_ logger: Logger) {
        do {
            try generate()
        }
        catch let error as ConfigLoader.Error {
            switch error {
            case .missing(let url):
                logger.error("Missing `config.yml` file at: `\(url.absoluteString)`.")
            case .file(let error):
                logger.error("Config file error: `\(error.localizedDescription)`")
            case .yaml(let error):
                logger.error("Config YAML error: `\(error.localizedDescription)`")
            }
        }
        catch let error as PageBundleLoader.Error {
            switch error {
            case .pageBundle(let error):
                logger.error("Page bundle error: `\(error.localizedDescription)`")
            }
        }
        catch {
            logger.error("\(error.localizedDescription)")
        }
    }
}
 
