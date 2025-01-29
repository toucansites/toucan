//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public enum Operator {
    case equals  // int, double, bool, string
    case notEquals  // int, double, bool, string

    case lessThan  // int, double
    case greaterThan  // int, double
    case lessThanOrEquals  // int, double
    case greaterThanOrEquals  // int, double

    case like  // string
    case caseInsensitiveLike  // string

    case `in`  // array of anything // field is a single value check is in array of values
    case contains  // single value // field is an array check contains single value
}
