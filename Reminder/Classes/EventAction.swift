//
//  ReminderEventAction.swift
//  AIFlatSwitch
//
//  Created by brennobemoura on 29/04/19.
//

import Foundation

open class EventAction: Event<ReminderStatus> {
    
    static func create(status: ReminderStatus) -> Self {
        return self.empty().update(status)
    }
    
    open func update(with status: ReminderStatus) {
        if case .later(let time) = status {
            Block(self.action(), priority: .later(.init(), time)).append()
            self.update(.notDetermined).save()
            return
        }
        
        if case .success = status {
            self.onSuccess()
        }
        
        self.update(status).save()
    }
    
    open func action() -> Action {
        return .init(async: { asyncBlock in
            self.async({ status in
                self.update(with: status)
                asyncBlock(status)
            })
        })
    }
    
    open func async(_ completion: @escaping (ReminderStatus) -> Void) {
        fatalError("Override action")
    }
    
    open func onSuccess() {}
    
    public override class func get() -> Self {
        guard let event: Event<ReminderStatus> = super.get() else {
            return .create(status: .notDetermined)
        }
        
        return .create(status: event.payload.value)
    }
    
    public static func runNow() {
        Queue.shared.append([Block(self.create(status: .notDetermined).action())])
    }
    
    open var scheduleTime: TimeInterval {
        return 12*3600
    }
    
    private static func asBlock() -> Block? {
        //print(self.description)
        let event = self.get()
        if case .success(let date) = event.payload.value {
            guard let priority = event.successPriority(from: date) else {
                return nil
            }
            return .init(event.action(), priority: priority)
        }
        
        if case .notDetermined = event.payload.value {
            return .init(event.action())
        }
        
        guard case .denied(let date) = event.payload.value else {
            return nil
        }
        
        if event.shouldRunNow {
            return .init(event.action())
        }
        
        return .init(event.action(), priority: .later(date, event.scheduleTime))
    }
    
    open func successPriority(from date: Date) -> Block.Priority? {
        return nil
    }
    
    public static func schedule() {
        //print(self.description)
        self.asBlock()?.append()
    }
    
    open var shouldRunNow: Bool {
        return true
    }
}
