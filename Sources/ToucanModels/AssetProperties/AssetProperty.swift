//
//  AssetProperty.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 21..
//

//public struct AssetProperty: Codable, Equatable {
//    public let action: Action
//    public let property: String
//    public let resolvePath: Bool
//    public let file: File
//
//    public init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.action = try container.decode(
//            AssetProperty.Action.self,
//            forKey: .action
//        )
//        self.property = try container.decode(String.self, forKey: .property)
//        self.resolvePath =
//            (try? container.decode(Bool.self, forKey: .resolvePath)) ?? false
//        self.file = try container.decode(AssetProperty.File.self, forKey: .file)
//    }
//}
