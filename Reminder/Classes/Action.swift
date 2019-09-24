//
//  ReminderAction.swift
//  TokBeauty
//
//  Created by brennobemoura on 29/04/19.
//  Copyright © 2019 TokBeauty. All rights reserved.
//

import Foundation

public enum ActionBlock {
    case async((@escaping (ReminderStatus) -> Void) -> Void)
    case block(() -> ReminderStatus)
    
    static func asyncEvent<T: EventAction>(_ type: T.Type) -> ActionBlock {
        return .async({ asyncBlock in
            type.async({ status in
                type.get().update(with: status)
                asyncBlock(status)
            })
        })
    }
}

public class Action {
    private let block: ActionBlock
    
    init(block: ActionBlock) {
        self.block = block
    }
    
    func run(_ completion: ((ReminderStatus) -> Void)? = nil) {
        switch self.block {
        case .async(let asyncBlock):
            self.saveExecution(.running)
            
            OperationQueue.main.addOperation {
                asyncBlock { [weak self] status in
                    completion?(status)
                    self?.release()
                }
            }
            return
        case .block(let function):
            self.saveExecution(.running)
            
            let executionResponse = function()
            completion?(executionResponse)
            self.release()
            return
        }
    }
    
    enum Execution {
        case released
        case running
        case notRunning
        case error
    }
    
    private var execution: Execution = .notRunning
    private func saveExecution(_ state: Execution) {
        if self.execution == .released { return }
        
        self.execution = state
        
        if state == .error {
            #if DEBUG
            print("[ReminderAction] Couldn't execute action")
            #endif
        }
    }
    
    func release() {
        self.saveExecution(.released)
    }
    
    func wait(for state: Execution) {
        while self.execution != state {
            usleep(1250000)
            if self.execution == .error {
                break
            }
        }
    }
}
