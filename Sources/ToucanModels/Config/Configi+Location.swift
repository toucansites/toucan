//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//


extension Config {

    public struct Location: Decodable {
        public var path: String
        
        // MARK: - init
        
        public init(
            path: String
        ) {
            self.path = path
        }
    }
}
