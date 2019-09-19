//
//  ReminderStatus.swift
//  TokBeauty
//
//  Created by brennobemoura on 29/04/19.
//  Copyright © 2019 TokBeauty. All rights reserved.
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
