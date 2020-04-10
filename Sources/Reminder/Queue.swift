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

public class Queue {
    var queue: [Block] = []
    
    lazy var dispatchQueue: DispatchQueue = {
        return .global(qos: .background)
    }()
    
    var isRunning: Bool = false {
        willSet {
            if !self.isRunning {
                if newValue {
                    self.dispatchQueue.resume()
                }
                
                return
            }
            
            if !newValue {
                self.dispatchQueue.suspend()
                ReminderConsole.print("[ReminderQueue] Suspended")
                Static.dealloc()
            }
        }
    }
    
    func schedule(_ block: Block) {
        guard case .later(let date, let time) = block.priority else {
            return
        }
        
        let runAt = (date.timeIntervalSince1970 + time) - Date().timeIntervalSince1970
        
        if runAt <= 0 {
            self.append(.init(block.action))
            return
        }
        
        ReminderConsole.print("[ReminderQueue] Scheduling")
        let afterBlock = Block.init(block.action)
        
        Static.background.asyncAfter(deadline: .now() + runAt, execute: {
            Static.create().append(afterBlock)
        })
    }
    
    func append(_ block: Block) {
        if case .later = block.priority {
            self.schedule(block)
            Static.dealloc()
            return
        }
        
        self.queue.append(block)
        self.async()
    }
    
    func append(_ blocks: [Block]) {
        blocks.forEach {
            self.append($0)
        }
    }
    
    private func wait() {
        while !self.queue.isEmpty {
            usleep(10000000)
            ReminderConsole.print("[ReminderQueue] Waiting")
        }
    }
    
    private func eat() -> Block? {
        guard !self.queue.isEmpty else {
            return nil
        }
        
        return self.queue.remove(at: 0)
    }
    
    private var startTime: TimeInterval {
        guard let delay = self.queue.first?.delay else {
            return 3
        }
        
        return delay > 0 ? delay : 3
    }
    
    private func async() {
        if self.isRunning || self.queue.isEmpty {
            return
        }
        
        self.isRunning = true
        self.dispatchQueue.async {
            let startTime = self.startTime
            for seconds in 0 ..< Int(startTime * 10) {
                if seconds % 10 == 0 {
                    ReminderConsole.print("[ReminderQueue] Running in \(Int(startTime) - seconds / 10) seconds")
                }
                usleep(100000)
            }
            
            Reminder.waitForViewController({
                DispatchQueue.global(qos: .background).async {
                    while let block = self.eat() {
                        block.run()
                    }
                }
            }, thread: self.dispatchQueue)
            
            self.wait()
            self.isRunning = false
        }
    }
    
    public static var shared: Queue {
        return Static.create()
    }
    
    private class Static {
        private static var _global: Queue?
        
        static var global: Queue? {
            return self._global
        }
        
        static var background: DispatchQueue = .global(qos: .background)
        
        static func create() -> Queue {
            if let global = self._global {
                return global
            }
            
            self._global = .init()
            return self._global!
        }
        
        static func dealloc() {
            self._global = nil
        }
    }
    
    deinit {
        ReminderConsole.print("Killed ReminderQueue")
    }
}
