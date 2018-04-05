//
//  JSON.swift
//  YFJSON
//
//  Created by Yuri Fox on 04.04.2018.
//  Copyright © 2018 Yuri Fox. All rights reserved.
//

import Foundation

public struct JSON {
    
    public private(set) var rawType: JSONType = .null
    
    private var object: Any {
        set {
            switch newValue {
            case let array as [Any]:
                self.rawType = .array
                self.rawArray = array
            case let dictionary as [String : Any]:
                self.rawType = .dictionary
                self.rawDictionary = dictionary
            case let number as NSNumber:
                if number.isBool {
                    self.rawType = .bool
                    self.rawBool = number.boolValue
                } else {
                    self.rawType = .number
                    self.rawNumber = number
                }
            case let string as String:
                self.rawType = .string
                self.rawString = string
            case let bool as Bool:
                self.rawType = .bool
                self.rawBool = bool
            default:
                self.rawNull = NSNull()
            }
            
        }
        get {
            switch self.rawType {
            case .array:
                return self.rawType
            case .dictionary:
                return self.rawDictionary
            case .number:
                return self.rawNumber.isBool ? self.rawBool : self.rawNumber
            case .string:
                return self.rawString
            case .bool:
                return self.rawBool
            default:
                return self.rawNull
            }
        }
    }
    
    private var rawArray: [Any] = []
    private var rawDictionary: [String: Any] = [:]
    private var rawString: String = ""
    private var rawNumber: NSNumber = 0
    private var rawBool: Bool = false
    private var rawNull: NSNull = NSNull()
    
    public init?(stringJSON: String, using encoding: String.Encoding = .utf8) {
        guard let data = stringJSON.data(using: encoding) else { return nil }
        self.init(data: data)
    }
    
    public init?(data: Data, options: JSONSerialization.ReadingOptions = []) {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: options) else { return nil }
        self.init(jsonObject: object)
    }
    
    private init() {
        self.init(jsonObject: NSNull())
    }
    
    private init(jsonObject: Any) {
        self.object = jsonObject
    }
    
}

// MARK: - JSONType
public enum JSONType: Int {
    case string
    case number
    case bool
    case array
    case dictionary
    case null
}

// MARK: - Subscript
public extension JSON {
    
    subscript(index: Int) -> JSON {
        guard self.rawType == .array, self.rawArray.indices.contains(index) else {
            return JSON()
        }
        return JSON(jsonObject: rawArray[index])
    }
    
    subscript(key: String) -> JSON {
        guard self.rawType == .dictionary, let dictionary = self.rawDictionary[key] else {
            return JSON()
        }
        return JSON(jsonObject: dictionary)
    }
    
}

// MARK: - Values
public extension JSON {
    
    var array: [JSON]? {
        guard self.rawType == .array else { return nil }
        return self.rawArray.map { JSON(jsonObject: $0) }
    }
    
    var dictionary: [String: JSON]? {
        guard self.rawType == .dictionary else { return nil }
        
        var dictionary: [String : JSON] = [:]
        
        for (key, value) in self.rawDictionary {
            dictionary[key] = JSON(jsonObject: value)
        }
        
        return dictionary
        
    }
    
    var number: NSNumber? {
        switch self.rawType {
        case .number:
            return self.rawNumber
            
        case .string:
            let decimal = NSDecimalNumber(string: self.rawString)
            return (decimal == NSDecimalNumber.notANumber) ? nil : decimal
            
        case .bool:
            return NSNumber(value: self.rawBool)
            
        default:
            return nil
        }
    }
    
    var int: Int? {
        return self.number?.intValue
    }
    
    var float: Float? {
        return self.number?.floatValue
    }
    
    var double: Double? {
        return self.number?.doubleValue
    }
    
    var string: String? {
        switch self.rawType {
        case .string:
            return self.rawString
            
        case .bool:
            return self.rawBool ? "true" : "false"
            
        case .number:
            return self.rawNumber.stringValue
            
        default:
            return nil
        }
    }
    
    var bool: Bool? {
        switch self.rawType {
        case .bool:
            return self.rawBool
            
        case .number:
            return Bool(exactly: self.rawNumber)
            
        case .string:
            if ["true", "yes", "t", "y", "1"].contains(self.rawString) {
                return true
            } else if ["false", "no", "f", "n", "0"].contains(self.rawString) {
                return false
            } else {
                return nil
            }
            
        default:
            return nil
        }
    }
    
    var url: URL? {
        guard self.rawType == .string else { return nil }
        
        if let url = URL(string: self.rawString) {
            return url
        } else if let encodedString = self.rawString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: encodedString)
        } else {
            return nil
        }
        
    }
    
    var null: NSNull? {
        return self.rawType == .null ? NSNull() : nil
    }
    
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible
extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        
        switch self.rawType {
        case .array:
            return self.rawArray.description
        case .dictionary:
            return self.rawDictionary.description
        case .number:
            return self.rawNumber.description
        case .string:
            return self.rawString
        case .bool:
            return self.rawBool.description
        default:
            return self.rawNull.description
        }
        
        
    }
    
    public var debugDescription: String {
        return description
    }
    
}

// MARK: - Equatable
extension JSON: Equatable {
    
    public static func == (lhs: JSON, rhs: JSON) -> Bool {
        
        switch (lhs.rawType, rhs.rawType) {
        case (.number, .number):
            return lhs.rawNumber == rhs.rawNumber
        case (.string, .string):
            return lhs.rawString == rhs.rawString
        case (.bool, .bool):
            return lhs.rawBool == rhs.rawBool
        case (.array, .array):
            return lhs.rawArray as NSArray == rhs.rawArray as NSArray
        case (.dictionary, .dictionary):
            return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
        case (.null, .null):
            return true
        default:
            return false
        }
    }
    
}

// MARK: - NSNumber + Extension
fileprivate extension NSNumber {
    
    private var trueNumber: NSNumber { return NSNumber(value: true) }
    private var falseNumber: NSNumber { return NSNumber(value: false) }
    private var trueObjCType: String { return String(cString: trueNumber.objCType) }
    private var falseObjCType: String { return String(cString: falseNumber.objCType) }
    
    fileprivate var isBool: Bool {
        let objCType = String(cString: self.objCType)
        return (self.compare(trueNumber) == .orderedSame && objCType == trueObjCType) || (self.compare(falseNumber) == .orderedSame && objCType == falseObjCType)
    }
    
}
