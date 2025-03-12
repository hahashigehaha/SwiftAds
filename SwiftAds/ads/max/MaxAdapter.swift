//
//  MaxAdapter.swift
//  SwiftAds
//
//  Created by lbe on 2025/3/11.
//
class MaxAdapter: AdsAdapter {
    
    func loadFullScreenAds(config: [String : Any]) async -> (any SwiftFullScreenAds)? {
        return nil
    }
    
    func loadViewAds(config: [String : Any]) async -> (any SwiftViewAds)? {
        return nil
    }
    
    func initAdapter(config: [String : Any]) {
        
    }
    
    
}


