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

public class Block {
    public enum Priority {
        case now(TimeInterval)
        case later(Date, TimeInterval)
    }
    
    let action: ActionBlock
    let priority: Priority
    
    init(_ action: ActionBlock, delay: TimeInterval = 0) {
        self.action = action
        self.priority = .now(delay)
    }
    
    init(_ action: ActionBlock, priority: Priority) {
        self.action = action
        
        switch priority {
        case .now(let delay):
            self.priority = .now(delay)
            
        case .later(let date, let time):
            let run = date.timeIntervalSince(Date()) + time
            
            if run <= 0 {
                self.priority = .now(0)
                return
            }
            
            self.priority = .later(date, run)
        }
    }
    
    func run() {
        let action = Action(block: self.action)
        OperationQueue.main.addOperation {
            action.run()
        }
        
        action.wait(for: .released)
        usleep(useconds_t(self.delay) * 1000000)
    }
    
    var delay: TimeInterval {
        guard case .now(let timeInterval) = self.priority, timeInterval > 0 else {
            return 0
        }
        
        return timeInterval
    }
    
    func publish() {
        Queue.shared.append(self)
    }
}
