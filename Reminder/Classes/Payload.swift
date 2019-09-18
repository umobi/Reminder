//
//  ReminderPayload.swift
//  Reminder
//
//  Created by brennobemoura on 05/09/19.
//

import Foundation

public protocol ReminderMappable {
    func toJSON() -> [String: Any]
    static func fromJSON(_ JSON: [String: Any]) -> Self?
}

public class Payload<Element> {
    private let _value: Element?
    public var value: Element {
        return self._value!
    }
    
    public init(_ value: Element) {
        self._value = value
    }
    
    private init() {
        self._value = nil
    }
    
    public static var empty: Payload<Element> {
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
        
        guard let value: Element = ({
            if let dict = valueKey as? [String: Any] {
                if let mappableType = Element.self as? ReminderMappable.Type {
                    return mappableType.fromJSON(dict) as? Element
                }
                
                if let decodableType = Element.self as? Decodable.Type, let object = try? decodableType.init(JSON: dict) as? Element {
                    return object
                }
            }
            
            return valueKey as? Element
        }()) else {
            return nil
        }
        
        self.init(value)
    }
}

extension Encodable {
    func asObject() throws -> [String: Any] {
        return (try JSONSerialization.jsonObject(with: try JSONEncoder().encode(self), options: .allowFragments) as? [String : Any]) ?? [:]
    }
}

extension Decodable {
    init?(JSON: Any) throws {
        self = try JSONDecoder().decode(Self.self, from: try JSONSerialization.data(withJSONObject: JSON, options: []))
    }
}
