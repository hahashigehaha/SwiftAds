//
//  ThreadSafeDictionary<.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/14.
//

import Foundation

class ThreadSafeDictionary<Key: Hashable, Value> {
    private var dictionary = [Key: Value]()
    private let queue = DispatchQueue(label: "com.example.dictionary", attributes: .concurrent)

    func getValue(forKey key: Key) -> Value? {
        queue.sync { dictionary[key] }
    }

    func setValue(_ value: Value, forKey key: Key) {
        queue.async(flags: .barrier) { [weak self] in
            self?.dictionary[key] = value
        }
    }
    // 获取所有 values
    var values:[Value] {
        queue.sync { Array(dictionary.values) }
    }
    // 移除所有元素
    func removeAll() {
        queue.async(flags: .barrier) { [weak self] in
            self?.dictionary.removeAll()
        }
    }
}
