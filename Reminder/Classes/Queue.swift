//
//  ReminderQueue.swift
//  TokBeauty
//
//  Created by brennobemoura on 29/04/19.
//  Copyright © 2019 TokBeauty. All rights reserved.
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
    
    private func async() {
        if self.isRunning || self.queue.isEmpty {
            return
        }
        
        self.isRunning = true
        self.dispatchQueue.async {
            for seconds in 0 ..< 3 {
                ReminderConsole.print("[ReminderQueue] Running in \(3 - seconds) seconds")
                usleep(1000000)
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
