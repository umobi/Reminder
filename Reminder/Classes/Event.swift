//
//  ReminderEvent.swift
//  Pods-Reminder_Tests
//
//  Created by brennobemoura on 05/09/19.
//

import Foundation

open class Event<T> {
    public let name: String
    public let payload: Payload<T>
    
    public static func empty() -> Self {
        return .init(String(describing: self))
    }
    
    required public init(_ name: String) {
        self.name = name
        self.payload = .empty
    }
    
    required public init(_ name: String, value: T) {
        self.name = name
        self.payload = .init(value)
    }
    
    public func save() {
        Reminder.shared.update(for: self)
    }
    
    public class func get() -> Self? {
        return Reminder.shared.get(for: self.empty())
    }
    
    public func restore() -> Self? {
        return Reminder.shared.get(for: self)
    }
    
    public func delete() {
        Reminder.shared.reset(for: self)
    }
    
    final public func asObject() -> [String: Any] {
        return [
            "name": self.name,
            "payload": self.payload.asObject()
        ]
    }
    
    public func update(_ value: T) -> Self {
        return .init(self.name, value: value)
    }
    
    open var value: T {
        return self.payload.value
    }
    
    public required init?(JSON: Any?) {
        guard let dic = JSON as? [String: Any],
            let name = dic["name"] as? String,
            let payload = Payload<T>(JSON: dic["payload"]) else {
                return nil
        }
        
        self.name = name
        self.payload = payload
    }
}
