//
//  ReminderAction.swift
//  TokBeauty
//
//  Created by brennobemoura on 29/04/19.
//  Copyright © 2019 TokBeauty. All rights reserved.
//

import Foundation

public class Action {
    let object: Any
    
    init(function: @escaping () -> ReminderStatus) {
        self.object = function
    }
    
    init(async: @escaping (@escaping (ReminderStatus) -> Void) -> Void) {
        self.object = async
    }
    
    func run(_ completion: ((ReminderStatus) -> Void)? = nil) {
        if let function = self.object as? () -> ReminderStatus {
            self.saveExecution(.running)
            
            let executionResponse = function()
            completion?(executionResponse)
            self.release()
            return
        }
        
        if let asyncBlock = self.object as? (@escaping (ReminderStatus) -> Void) -> Void {
            self.saveExecution(.running)
            
            OperationQueue.main.addOperation {
                asyncBlock { [weak self] status in
                    completion?(status)
                    self?.release()
                }
            }
            return
        }
        
        self.saveExecution(.error)
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
