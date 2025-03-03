//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 03..
//

import Foundation
import ToucanModels

extension Origin {
    
    func detectContentDefinition(
        in contentDefinitions: [ContentDefinition],
        explicitTypeId: String?
    ) -> ContentDefinition? {
        var assumedType: String?
        
        for contentDefinition in contentDefinitions {
            let matchingPrefixes = contentDefinition.paths
                .filter {
                    path.hasPrefix($0)
                }
            
            if !matchingPrefixes.isEmpty {
                assumedType = contentDefinition.type
            }
        }

        if let explicitTypeId {
            assumedType = explicitTypeId
        }
        
        return contentDefinitions.first {
            $0.type == assumedType
        }
    }
}
