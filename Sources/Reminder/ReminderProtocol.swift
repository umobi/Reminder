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
