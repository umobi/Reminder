//
//  Reminder.swift
//  Reminder
//
//  Created by Ramon Vicente on 7/21/18.
//  Copyright © 2018 TokBeauty. All rights reserved.
//

import Foundation
import UIKit

public protocol UIReminderWindow {
    var visibleViewController: UIViewController? { get }
}

protocol ReminderProtocol: class {
    init()
    
    static var __shared: Self? { get set }
    static var waitingSeconds: TimeInterval { get }
}

extension ReminderProtocol {
    
    static var shared: Self {
        let shared = self.__shared ?? Self.init()
        self.__shared = shared
        return shared
    }
    
    static var waitingSeconds: TimeInterval {
        return .init(5)
    }
    
    private var controller: UserDefaults {
        return UserDefaults.standard
    }
}

extension ReminderProtocol {
    public static func waitForViewController(_ completion: @escaping (() -> Void), thread: DispatchQueue? = nil) {
        (thread ?? DispatchQueue.global(qos: .background)).async {
            var isBusy = false
            repeat {
                
                DispatchQueue.main.sync {
                    isBusy = (UIApplication.shared.keyWindow as? UIReminderWindow)?.visibleViewController == nil ||
                        (UIApplication.shared.keyWindow as? UIReminderWindow)?.visibleViewController is UIAlertController
                }
                
                guard isBusy else {
                    break
                }
                
                ReminderConsole.print("[Reminder] Waiting for Window.visibleViewController")
                usleep(useconds_t(1)*1000000)
            } while isBusy
            
            completion()
        }
    }
}

extension ReminderProtocol {
    func reset<E, P>(for event: E?) where E: Event<P> {
        guard let event = event else { return }
        
        self.controller.set(nil, forKey: event.name)
        self.controller.synchronize()
    }
    
    func update<E, P>(for event: E) where E: Event<P> {
        self.controller.set(event.asObject(), forKey: event.name)
        self.controller.synchronize()
    }
    
    func get<E, P>(for event: E) -> E? where E: Event<P> {
        return self.controller.object(forKey: event.name).flatMap { E(JSON: $0) }
    }
}

class ReminderConsole {
    public static func print(_ items: Any...) {
        #if DEBUG
        //Swift.print("[Reminder] ", terminator: "")
        items.forEach {
            Swift.print($0, terminator: "")
        }
        Swift.print()
        #endif
    }
}

final class Reminder: ReminderProtocol {
    static weak var __shared: Reminder?
}
