//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

// TODO: maybe use =, !=, >, >=, <, <= values
public enum Operator: String {

    // int, double, bool, string
    case equals

    // int, double, bool, string
    case notEquals

    // int, double
    case lessThan

    // int, double
    case lessThanOrEquals

    // int, double
    case greaterThan

    // int, double
    case greaterThanOrEquals

    // string
    case like

    // string
    case caseInsensitiveLike

    // field is a single value check is in array of values
    // array of anything
    case `in`

    // field is an array check contains single value
    // single value
    case contains
}
