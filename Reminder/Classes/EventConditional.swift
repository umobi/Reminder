//
//  EventConditional.swift
//  Reminder
//
//  Created by brennobemoura on 05/09/19.
//

import Foundation

open class EventConditional<T>: Event<T> {
    static func create() -> Self {
        return .init(self.description)
    }
    
    static var description: String {
        return String(describing: self)
    }
    
    override public func update(_ value: T) -> Self {
        if shouldUpdate(value) {
            return .init(self.name, value: value)
        }
        
        return self
    }
    
    open func shouldUpdate(_ newValue: T) -> Bool {
        return true
    }
}

public protocol ActionController {
    static var actions: [EventAction.Type] { get }
}

public extension ActionController {
    static func run() {
        self.actions.forEach {
            Publish.create($0).runNow()
        }
    }
}

public protocol EventKey: RawRepresentable where RawValue == String {
    func update<T>(_ value: T)
    func remove()
    func restore<T>(_ value: T.Type) -> Event<T>?
}

public extension EventKey {
    private var name: String {
        return "EventKey.\(self.rawValue)"
    }
    
    func update<T>(_ value: T) {
        Event<T>(self.name, value: value).save()
    }
    
    func remove() {
        Event<Void>(self.name).delete()
    }
    
    func restore<T>(_ value: T.Type) -> Event<T>? {
        return Event<T>(self.name).restore()
    }
}
