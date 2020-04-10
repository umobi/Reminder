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
