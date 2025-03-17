//
//  SafeCounter.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/17.
//
import Foundation

class SafeCounter {
    private var count = 0
    private let queue = DispatchQueue(label: "com.swift.counterQueue", attributes: .concurrent)
    
    func reset() {
        queue.async(flags: .barrier) {
            self.count = 0
        }
    }

    func increment() {
        queue.async(flags: .barrier) {
            self.count += 1
        }
    }

    func getCount() -> Int {
        return queue.sync { count }
    }
}
