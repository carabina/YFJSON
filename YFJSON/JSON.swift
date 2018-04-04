//
//  JSON.swift
//  YFJSON
//
//  Created by Yuri Fox on 04.04.2018.
//  Copyright © 2018 Yuri Fox. All rights reserved.
//

import Foundation

public struct JSON {
    
    public var rawType: JSONRawType {
        switch self.object {
        case is String:
            return .string
        case let number as NSNumber:
            return number.isBool ? .bool : .number
        case is [Any]:
            return .array
        case is [String : Any]:
            return .dictionary
        default:
            return .null
        }
        
    }
    
    private var object: Any
    
    public init() {
        self.init(jsonObject: NSNull())
    }
    
    public init?(stringJSON: String, using encoding: String.Encoding = .utf8) {
        guard let data = stringJSON.data(using: encoding) else { return nil }
        self.init(data: data)
    }
    
    public init?(data: Data, options: JSONSerialization.ReadingOptions = []) {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: options) else { return nil }
        self.init(jsonObject: object)
    }
    
    private init(jsonObject: Any) {
        self.object = jsonObject
    }
    
}

// MARK: - Subscript
public extension JSON {
    
    subscript(index: Int) -> JSON {
        guard let rawArray = self.object as? [Any], rawArray.indices.contains(index) else { return JSON() }
        return JSON(jsonObject: rawArray[index])
    }
    
    subscript(key: String) -> JSON {
        guard let rawDictionary = (self.object as? [String : Any])?[key] else { return JSON() }
        return JSON(jsonObject: rawDictionary)
    }
    
}

// MARK: - Values
public extension JSON {
    
    var int: Int? {
        return self.number?.intValue
    }
    
    var float: Float? {
        return self.number?.floatValue
    }
    
    var double: Double? {
        return self.number?.doubleValue
    }
    
    var number: NSNumber? {
        switch self.object {
        case let number as NSNumber:
            return number
            
        case let string as String:
            let decimal = NSDecimalNumber(string: string)
            return (decimal == NSDecimalNumber.notANumber) ? nil : decimal
            
        case let bool as Bool:
            return NSNumber(value: bool)
            
        default:
            return nil
        }
    }
    
    var string: String? {
        switch self.object {
        case let string as String:
            return string
            
        case let bool as Bool:
            return bool ? "true" : "false"
            
        case is NSNumber:
            return self.number?.stringValue
            
        default:
            return nil
        }
    }
    
    var bool: Bool? {
        switch self.object {
        case let bool as Bool:
            return bool
            
        case let number as NSNumber:
            return Bool(exactly: number)
            
        case let string as String:
            if ["true", "yes", "t", "y", "1"].contains(string) {
                return true
            } else if ["false", "no", "f", "n", "0"].contains(string) {
                return false
            } else {
                return nil
            }
            
        default:
            return nil
        }
    }
    
    var url: URL? {
        guard let string = self.string else { return nil }
        
        if let url = URL(string: string) {
            return url
        } else if let encodedString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: encodedString)
        } else {
            return nil
        }
        
    }
    
    var null: NSNull? {
        guard self.rawType == .null else { return nil }
        return NSNull()
    }
    
}

/// JSONRawType
public enum JSONRawType: Int {
    case string
    case number
    case bool
    case array
    case dictionary
    case null
}

// MARK: - NSNumber + Extension
extension NSNumber {
    
    private var trueNumber: NSNumber { return NSNumber(value: true) }
    private var falseNumber: NSNumber { return NSNumber(value: false) }
    private var trueObjCType: String { return String(cString: trueNumber.objCType) }
    private var falseObjCType: String { return String(cString: falseNumber.objCType) }
    
    fileprivate var isBool: Bool {
        let objCType = String(cString: self.objCType)
        return (self.compare(trueNumber) == .orderedSame && objCType == trueObjCType) || (self.compare(falseNumber) == .orderedSame && objCType == falseObjCType)
    }
    
}
