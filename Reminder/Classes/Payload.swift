//
//  ReminderPayload.swift
//  Reminder
//
//  Created by brennobemoura on 05/09/19.
//

import Foundation

public protocol ReminderMappable {
    func toJSON() -> [String: Any]
    init?(JSON: [String: Any])
}

public class Payload<T> {
    private let _value: T?
    public var value: T {
        return self._value!
    }
    
    public init(_ value: T) {
        self._value = value
    }
    
    private init() {
        self._value = nil
    }
    
    public static var empty: Payload<T> {
        return .init()
    }
    
    public final var isEmpty: Bool {
        return self._value == nil
    }
    
}

public extension Payload {
    func asObject() -> [String: Any] {
        if self.isEmpty {
            return [:]
        }
        
        return ["value": {
            if let mappable = self.value as? ReminderMappable {
                return mappable.toJSON()
            }
            
            if let codable = self.value as? Encodable, let object = try? codable.asObject() {
                return object
            }
            
            return self.value
        }()]
    }
    
    convenience init?(JSON: Any?) {
        guard let dict = JSON as? [String: Any] else {
            return nil
        }
        
        if dict.isEmpty {
            self.init()
            return
        }
        
        
        guard let valueKey = dict["value"] else {
            return nil
        }
        
        guard let value: T = ({
            if let dict = valueKey as? [String: Any] {
                if let mappableType = T.self as? ReminderMappable.Type {
                    return mappableType.init(JSON: dict) as? T
                }
                
                if let decodableType = T.self as? Decodable.Type, let object = try? decodableType.init(JSON: dict) as? T {
                    return object
                }
            }
            
            return valueKey as? T
        }()) else {
            return nil
        }
        
        self.init(value)
    }
}

public extension Encodable {
    func asObject() throws -> [String: Any] {
        return (try JSONSerialization.jsonObject(with: try JSONEncoder().encode(self), options: .allowFragments) as? [String : Any]) ?? [:]
    }
}

public extension Decodable {
    init?(JSON: Any) throws {
        self = try JSONDecoder().decode(Self.self, from: try JSONSerialization.data(withJSONObject: JSON, options: []))
    }
}
