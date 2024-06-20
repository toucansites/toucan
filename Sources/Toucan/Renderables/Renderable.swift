//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 20/06/2024.
//

import Foundation

struct Renderable<T> {
    let template: String
    let context: T
    let destination: URL
}
