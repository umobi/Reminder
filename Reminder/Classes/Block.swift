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
        case now
        case later(Date, TimeInterval)
    }
    
    let action: Action
    let priority: Priority
    
    init(_ action: Action) {
        self.action = action
        self.priority = .now
    }
    
    init(_ action: Action, priority: Priority) {
        self.action = action
        
        guard case .later(let date, let time) = priority else {
            self.priority = .now
            return
        }
        
        let run = date.timeIntervalSince(Date()) + time
        
        if run <= 0 {
            self.priority = .now
            return
        }
        
        self.priority = .later(date, run)
    }
    
    func run() {
        OperationQueue.main.addOperation {
            self.action.run()
        }
        
        action.wait(for: .released)
        usleep(1000000)
    }
    
    func append() {
        Queue.shared.append(self)
    }
}
