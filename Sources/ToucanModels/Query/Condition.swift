//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public enum Condition {
    case field(key: String, operator: Operator, value: Any)
    case and([Condition])
    case or([Condition])
}
