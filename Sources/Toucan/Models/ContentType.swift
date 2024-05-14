//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/05/2024.
//

import Foundation

protocol ContentType {
    var id: String { get }
    var slug: String { get }
    var meta: Meta { get }
    var publication: Date { get }
    var lastModification: Date { get }
    var variables: [String: String] { get }
    var markdown: String { get }
}
