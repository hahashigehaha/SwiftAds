//
//  SwiftEventDelegate.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/13.
//
protocol SwiftEventDelegate: AnyObject {
    
    func onEvent(eventName: String,params: [String : Any])
    
}
