//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public enum Operator: String {

    // int, double, bool, string
    case equals

    // int, double, bool, string
    case notEquals = "not-equals"

    // int, double
    case lessThan = "less-than"

    // int, double
    case lessThanOrEquals = "less-than-or-equals"

    // int, double
    case greaterThan = "greater-than"

    // int, double
    case greaterThanOrEquals = "greater-than-or-equals"

    // string
    case like

    // string
    case caseInsensitiveLike = "case-insensitive-like"

    // field is a single value check is in array of values
    // array of anything
    case `in`

    // field is an array check contains single value
    // single value
    case contains
}
