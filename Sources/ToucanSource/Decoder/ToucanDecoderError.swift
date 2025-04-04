//
//  ToucanDecoderError.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 04.
//
    
public enum ToucanDecoderError: Error {
    case decoding(Error, Any.Type)
}
