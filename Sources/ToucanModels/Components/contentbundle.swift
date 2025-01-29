//
//  contentbundle.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

import Foundation

struct ContentBundle {
    var contentType: ContentType
    var pageBundles: [PageBundle]
    
    mutating func loadFields(pageBundle: PageBundle) -> PageBundle {
        
        var pageBundle = pageBundle
        
        let formatter = DateFormatter()

        for property in contentType.properties {
            
            let rawValue = pageBundle.frontMatter[property.key]
            
            if property.required, rawValue == nil {
                print("ERROR: property is missing (\(property.key).")
            }

            let anyValue = rawValue ?? property.default
            
            var wrapper: TypeWrapper!
            
            switch property.type {
            case .bool:
                guard let value = anyValue as? Bool else {
                    print("ERROR: property is not a bool (\(property.key): \(anyValue ?? "nil")).")
                    break
                }
                wrapper = .bool(value)
            case .int:
                guard let value = anyValue as? Int else {
                    print("ERROR: property is not an integer (\(property.key): \(anyValue ?? "nil")).")
                    break
                }
                wrapper = .int(value)
            case .double:
                guard let value = anyValue as? Double else {
                    print("ERROR: property is not a double (\(property.key): \(anyValue ?? "nil")).")
                    break
                }
                wrapper = .double(value)
            case .string:
                guard let value = anyValue as? String else {
                    print("ERROR: property is not a string (\(property.key): \(anyValue ?? "nil")).")
                    break
                }
                wrapper = .string(value)
            case let .date(format):
                guard let rawDateValue = anyValue as? String else {
                    print("ERROR: property is not a string (\(property.key): \(anyValue ?? "nil")).")
                    break
                }
                formatter.dateFormat = format
                guard let value = formatter.date(from: rawDateValue) else {
                    print("ERROR: property is not a date (\(property.key): \(anyValue ?? "nil")).")
                    break
                }
                wrapper = .date(value.timeIntervalSince1970)
            }
            
            pageBundle.properties[property.key] = wrapper

        }
        return pageBundle
        
    }
}



