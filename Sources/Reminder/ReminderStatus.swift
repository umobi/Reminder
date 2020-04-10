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

public enum ReminderStatus {
    case success(Date)
    case denied(Date)
    case disabled
    case notDetermined
    case later(TimeInterval)
    
    case error(Swift.Error?)
    
    public var raw: Int {
        switch self {
        case .error:
            return 0
        case .success:
            return 1
        case .denied:
            return 2
        case .disabled:
            return 3
        case .notDetermined:
            return 4
        case .later:
            return 5
        }
    }
    
    init?(rawValue: Int, value: Any? = nil) {
        switch rawValue {
        case 0: self = .error(nil)
        case 1:
            guard let date = value as? Date else {
                return nil
            }
            self = .success(date)
            
        case 2:
            guard let date = value as? Date else {
                return nil
            }
            self = .denied(date)
            
        case 3: self = .disabled
        case 4: self = .notDetermined
            
        case 5:
            guard let time = value as? TimeInterval else {
                return nil
            }
            self = .later(time)
            
        default: return nil
        }
    }
}

extension ReminderStatus: ReminderMappable {
    public static func fromJSON(_ JSON: [String : Any]) -> ReminderStatus? {
        guard let raw = JSON["raw"] as? Int else {
            return nil
        }
        
        return ReminderStatus(rawValue: raw, value: JSON["value"])
    }
    
    public func toJSON() -> [String : Any] {
        switch self {
        case .denied(let date):
            return ["raw": self.raw, "value": date]
        case .later(let time):
            return ["raw": self.raw, "value": time]
        case .success(let time):
            return ["raw": self.raw, "value": time]
        default:
            return ["raw": self.raw]
        }
    }
}
