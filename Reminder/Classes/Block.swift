//
//  RQueueBlock.swift
//  TokBeauty
//
//  Created by brennobemoura on 29/04/19.
//  Copyright © 2019 TokBeauty. All rights reserved.
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
