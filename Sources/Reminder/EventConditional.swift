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
