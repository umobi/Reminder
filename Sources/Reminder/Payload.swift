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
    func asObject() throws -> [String: Any]? {
        return (try JSONSerialization.jsonObject(with: try JSONEncoder().encode(self), options: .allowFragments) as? [String : Any])
    }
}

extension Decodable {
    init?(JSON: Any) throws {
        self = try JSONDecoder().decode(Self.self, from: try JSONSerialization.data(withJSONObject: JSON, options: []))
    }
}
