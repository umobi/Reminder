//
// Copyright (c) 2019-Present Umobi - https://github.com/umobi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

open class EventAction: Event<ReminderStatus> {
    
    static func create(status: ReminderStatus) -> Self {
        return self.empty().update(status)
    }
    
    open func update(with status: ReminderStatus) {
        if case .later(let time) = status {
            Block(.asyncEvent(Self.self), priority: .later(.init(), time)).publish()
            self.update(.notDetermined).save()
            return
        }
        
        if case .success = status {
            self.onSuccess()
        }
        
        self.update(status).save()
    }
    
    open class func async(_ completion: @escaping (ReminderStatus) -> Void) {
        fatalError("Override action")
    }
    
    open func onSuccess() {}
    
    public override class func get() -> Self {
        guard let event: Event<ReminderStatus> = super.get() else {
            return .create(status: .notDetermined)
        }
        
        return .create(status: event.payload.value)
    }
    
    open var scheduleTime: TimeInterval {
        return 12*3600
    }
    
    open func successPriority(from date: Date) -> Block.Priority? {
        return nil
    }
    
    open var shouldRunNow: Bool {
        return true
    }
}

public class Publish<T: EventAction> {
    let type: T.Type
    
    private func asBlock(_ delay: TimeInterval) -> Block? {
        //print(self.description)
        let event = type.get()
        if case .success(let date) = event.payload.value {
            guard let priority = event.successPriority(from: date) else {
                return nil
            }
            return .init(.asyncEvent(type), priority: priority)
        }
        
        if case .notDetermined = event.payload.value {
            return .init(.asyncEvent(type))
        }
        
        guard case .denied(let date) = event.payload.value else {
            return nil
        }
        
        if event.shouldRunNow {
            return .init(.asyncEvent(type), delay: delay)
        }
        
        return .init(.asyncEvent(type), priority: .later(date, event.scheduleTime))
    }
    
    public func schedule(delay: TimeInterval = 0) {
        //print(self.description)
        self.asBlock(delay)?.publish()
    }
    
    public func runNow(delay: TimeInterval = 0) {
        Block(.asyncEvent(
            self.type//.create(status: .notDetermined)
        ), delay: delay).publish()
    }
    
    static func create(_ type: T.Type) -> Publish<T> {
        return .init(type)
    }
    
    private init(_ type: T.Type) {
        self.type = type
    }
}

public extension EventAction {
    static func asPublish() -> Publish<EventAction> {
        return Publish.create(self.self)
    }
}
