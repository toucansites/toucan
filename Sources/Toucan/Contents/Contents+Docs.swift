//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation

extension Site.Contents {
    
    struct Docs {
        
        struct Category {
            let material: SourceMaterial
            
        }

        struct Guide {
            let material: SourceMaterial
            
        }
        
        let categories: [Category]
        let guides: [Category]
    }

}
