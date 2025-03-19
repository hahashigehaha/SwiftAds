//
//  WeakDelegate.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/19.
//

// 定义一个弱引用包装类
class WeakEventDelegate {
    
    weak var delegate: SwiftEventDelegate?

    init(delegate: SwiftEventDelegate?) {
        self.delegate = delegate
    }
}
